//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import ExposureNotification
import Foundation
import UserNotifications

protocol ExposureManaging {}

public struct DetectionExposureManager: ExposureManaging {
    private static let oldestDownloadDate = DateComponents(day: -14)
    private static let keyStartDayThresholdWithOnsetDay = -2
    private static let keyStartDayThresholdWithSelfDiagnosisDay = -4
    private static let tenMinuteWindowDivider = 60.0 * 10 // From ENIntervallNumber documentation
    
    private var cancellables = [AnyCancellable]()
    
    struct ExposureDetectionError: Error {}
    
    var detectingExposures = false
    
    private let controller: ExposureNotificationDetectionController
    private let client: ExposureDetectionClient
    private let exposureDetectionStore: ExposureDetectionStore
    public typealias RiskCalculatorFactory = (ExposureDetectionConfiguration) -> ExposureRiskCalculating
    private let riskCalculator: RiskCalculatorFactory
    private let interestedInExposureNotifications: () -> Bool
    
    public init(
        manager: ExposureNotificationManaging,
        distributionClient: HTTPClient,
        submissionClient: HTTPClient,
        encryptedStore: EncryptedStoring,
        riskCalculator: @escaping RiskCalculatorFactory = ExposureRiskCalculator.init,
        interestedInExposureNotifications: @escaping () -> Bool
    ) {
        controller = ExposureNotificationDetectionController(manager: manager)
        client = ExposureDetectionClient(distributionClient: distributionClient, submissionClient: submissionClient)
        exposureDetectionStore = ExposureDetectionStore(store: encryptedStore)
        self.riskCalculator = riskCalculator
        self.interestedInExposureNotifications = interestedInExposureNotifications
    }
    
    public func sendKeys(
        token: DiagnosisKeySubmissionToken,
        onsetDay: GregorianDay?,
        selfDiagnosisDay: GregorianDay,
        isolationEndDate: Date
    ) -> AnyPublisher<Void, Error> {
        controller.getDiagnosisKeys()
            .map { diagnosisKeys in
                let relevantStartDate: GregorianDay
                if let onsetDay = onsetDay {
                    relevantStartDate = onsetDay.advanced(by: Self.keyStartDayThresholdWithOnsetDay)
                } else {
                    relevantStartDate = selfDiagnosisDay.advanced(by: Self.keyStartDayThresholdWithSelfDiagnosisDay)
                }
                
                let utcTimeZone = TimeZone(identifier: "UTC")!
                let startDateNumber = UInt32(relevantStartDate.startDate(in: utcTimeZone).timeIntervalSince1970 / Self.tenMinuteWindowDivider)
                let endDateNumber = UInt32(isolationEndDate.timeIntervalSince1970 / Self.tenMinuteWindowDivider)
                
                return diagnosisKeys.filter { diagnosisKey in
                    // relevantStartDate can be in the middle of an existing key - we also need to include that key
                    let extendedStartNumber = (startDateNumber - diagnosisKey.rollingPeriod)
                    
                    return extendedStartNumber < diagnosisKey.rollingStartNumber
                        && endDateNumber > diagnosisKey.rollingStartNumber
                }
            }
            .flatMap {
                self.client.post(token: token, diagnosisKeys: $0).mapError { $0 as Error }.eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private func riskInfo(for increment: Increment, using riskCalculator: ExposureRiskCalculating) -> AnyPublisher<RiskInfo?, Error> {
        Deferred { () -> AnyPublisher<RiskInfo?, Error> in
            guard self.interestedInExposureNotifications() else {
                return Empty<RiskInfo?, Error>().eraseToAnyPublisher()
            }
            return self.client.getExposureKeys(for: increment)
                .mapError { $0 as Error }
                .tryMap { zipManager -> ([URL], ZIPManager.Handler) in
                    let fileManager = FileManager()
                    let handler = try zipManager.extract(fileManager: fileManager)
                    
                    let urls = try fileManager.contentsOfDirectory(
                        at: handler.folderURL,
                        includingPropertiesForKeys: nil
                    )
                    
                    return (urls, handler)
                }
                .flatMap { (urls, handler) -> AnyPublisher<(ENExposureDetectionSummary, ZIPManager.Handler), Error> in
                    let handler = Result<ZIPManager.Handler, Error>.Publisher(.success(handler)).eraseToAnyPublisher()
                    let summary = self.controller.detectExposures(
                        configuration: riskCalculator.createExposureNotificationConfiguration(),
                        diagnosisKeyURLs: urls
                    )
                    
                    return Publishers.CombineLatest(summary, handler).eraseToAnyPublisher()
                }
                .flatMap { summary, handler in
                    self.controller.getExposureInfo(
                        summary: summary
                    )
                    .map { exposureInfo in
                        riskCalculator.riskInfo(for: exposureInfo)
                    }
                }
                .eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }
    
    public func detectExposures() -> AnyPublisher<RiskInfo?, Never> {
        client.getConfiguration()
            .catch { _ in Empty() }
            .map(riskCalculator)
            .flatMap { riskCalculator -> AnyPublisher<RiskInfo?, Never> in
                
                var risks: AnyPublisher<RiskInfo?, Error> = Empty().eraseToAnyPublisher()
                
                let oldestDownloadDate = Calendar.utc.date(byAdding: Self.oldestDownloadDate, to: Date())!
                var lastCheckDate = self.exposureDetectionStore.load()?.lastKeyDownloadDate ?? oldestDownloadDate
                
                while let incrementInfo = Increment.nextIncrement(lastCheckDate: lastCheckDate, now: Date()) {
                    lastCheckDate = incrementInfo.checkDate
                    let incrementRisk = self.riskInfo(for: incrementInfo.increment, using: riskCalculator)
                        .handleEvents(receiveCompletion: { completion in
                            if case .finished = completion {
                                self.exposureDetectionStore.save(lastKeyDownloadDate: incrementInfo.checkDate)
                            }
                        })
                    
                    risks = risks
                        .append(incrementRisk)
                        .eraseToAnyPublisher()
                }
                
                return risks
                    .replaceError(with: nil)
                    .scan(nil) { lhs, rhs -> RiskInfo? in
                        switch (lhs, rhs) {
                        case (.some(let lhs), .some(let rhs)):
                            return lhs.isHigherPriority(than: rhs) ? lhs : rhs
                        case (.some(let val), nil), (nil, .some(let val)):
                            return val
                        case (nil, nil):
                            return nil
                        }
                    }
                    .last()
                    .eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
}

public enum DetectionExposureManagerError: Error {
    case missingSubmissionToken
}
