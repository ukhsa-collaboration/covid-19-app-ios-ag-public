//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import ExposureNotification
import Foundation
import UserNotifications

struct ExposureDetectionManager {
    private static let oldestDownloadDate = DateComponents(day: -14)
    private static let tenMinuteWindowDivider = 60.0 * 10 // From ENIntervallNumber documentation
    
    private var cancellables = [AnyCancellable]()
    
    struct ExposureDetectionError: Error {}
    
    var detectingExposures = false
    
    private let controller: ExposureNotificationDetectionController
    private let client: ExposureDetectionClient
    private let exposureDetectionStore: ExposureDetectionStore
    private let transmissionRiskLevelApplier: TransmissionRiskLevelApplier
    typealias RiskCalculatorFactory = (ExposureDetectionConfiguration) -> ExposureRiskCalculating
    private let riskCalculator: RiskCalculatorFactory
    private let interestedInExposureNotifications: () -> Bool
    
    init(
        manager: ExposureNotificationManaging,
        distributionClient: HTTPClient,
        submissionClient: HTTPClient,
        encryptedStore: EncryptedStoring,
        transmissionRiskLevelApplier: TransmissionRiskLevelApplier,
        riskCalculator: @escaping RiskCalculatorFactory = ExposureRiskCalculator.withConfiguration,
        interestedInExposureNotifications: @escaping () -> Bool
    ) {
        controller = ExposureNotificationDetectionController(manager: manager)
        client = ExposureDetectionClient(distributionClient: distributionClient, submissionClient: submissionClient)
        exposureDetectionStore = ExposureDetectionStore(store: encryptedStore)
        self.riskCalculator = riskCalculator
        self.interestedInExposureNotifications = interestedInExposureNotifications
        self.transmissionRiskLevelApplier = transmissionRiskLevelApplier
    }
    
    func sendKeys(for onsetDay: GregorianDay, token: DiagnosisKeySubmissionToken) -> AnyPublisher<Void, Error> {
        controller.getDiagnosisKeys()
            .map {
                self.transmissionRiskLevelApplier.applyTransmissionRiskLevels(for: $0, onsetDay: onsetDay)
                    .filter { $0.transmissionRiskLevel > 0 }
            }
            .flatMap {
                self.client.post(token: token, diagnosisKeys: $0).mapError { $0 as Error }.eraseToAnyPublisher()
            }
            .eraseToAnyPublisher()
    }
    
    private func riskInfo(for increment: Increment, using riskCalculator: ExposureRiskCalculating) -> AnyPublisher<ExposureRiskInfo?, Error> {
        Deferred { () -> AnyPublisher<ExposureRiskInfo?, Error> in
            guard self.interestedInExposureNotifications() else {
                return Empty<ExposureRiskInfo?, Error>().eraseToAnyPublisher()
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
    
    func detectExposures(currentDate: Date) -> AnyPublisher<ExposureRiskInfo?, Never> {
        client.getConfiguration()
            .catch { _ in Empty() }
            .map(riskCalculator)
            .flatMap { riskCalculator -> AnyPublisher<ExposureRiskInfo?, Never> in
                
                var risks: AnyPublisher<ExposureRiskInfo?, Error> = Empty().eraseToAnyPublisher()
                
                let oldestDownloadDate = Calendar.utc.date(byAdding: Self.oldestDownloadDate, to: currentDate)!
                var lastCheckDate = self.exposureDetectionStore.load()?.lastKeyDownloadDate ?? oldestDownloadDate
                
                while let incrementInfo = Increment.nextIncrement(lastCheckDate: lastCheckDate, now: currentDate) {
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
                    .ensureFinishes(placeholder: nil)
                    .prepend(nil) // TODO: Why is this necessary? `last()` won’t complete if we complete with an empty upstream.
                    .scan(nil) { lhs, rhs -> ExposureRiskInfo? in
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
