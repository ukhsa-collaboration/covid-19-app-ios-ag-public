//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import ExposureNotification
import Foundation
import Logging
import UserNotifications

struct ExposureDetectionManager {
    
    private static let logger = Logger(label: "ExposureNotification")
    
    private static let oldestDownloadDate = DateComponents(day: -14)
    private static let tenMinuteWindowDivider = 60.0 * 10 // From ENIntervallNumber documentation
    
    private var cancellables = [AnyCancellable]()
    
    struct ExposureDetectionError: Error {}
    
    var detectingExposures = false
    
    private let controller: ExposureNotificationDetectionController
    private let client: ExposureDetectionEndpointManager
    private let exposureDetectionStore: ExposureDetectionStore
    private let interestedInExposureNotifications: () -> Bool
    private let exposureRiskManager: ExposureRiskManaging
    
    init(
        controller: ExposureNotificationDetectionController,
        distributionClient: HTTPClient,
        fileStorage: FileStorage,
        encryptedStore: EncryptedStoring,
        interestedInExposureNotifications: @escaping () -> Bool,
        exposureRiskManager: ExposureRiskManaging
    ) {
        client = ExposureDetectionEndpointManager(distributionClient: distributionClient, fileStorage: fileStorage)
        exposureDetectionStore = ExposureDetectionStore(store: encryptedStore)
        self.controller = controller
        self.interestedInExposureNotifications = interestedInExposureNotifications
        self.exposureRiskManager = exposureRiskManager
    }
    
    func detectExposures(currentDate: Date, sendFakeExposureWindows: @escaping () -> Void) -> AnyPublisher<ExposureRiskInfo?, Never> {
        guard detectionMatchesCheckFrequency(currentDate: currentDate) else {
            Self.logger.debug("Skipping detection to avoid reaching the rate limit early.")
            return Empty().eraseToAnyPublisher()
        }
        
        guard interestedInExposureNotifications() else {
            Self.logger.debug("Not interested in exposures. Skipping detection.")
            return downloadIncrementsWithoutProcessing(currentDate: currentDate, sendFakeExposureWindows: sendFakeExposureWindows)
        }
        
        return client.getConfiguration()
            .catch { _ in Empty() }
            .flatMap { configuration in
                self.detectExposures(currentDate: currentDate, configuration: configuration)
            }
            .eraseToAnyPublisher()
    }
    
    func downloadIncrementsWithoutProcessing(currentDate: Date, sendFakeExposureWindows: @escaping () -> Void) -> AnyPublisher<ExposureRiskInfo?, Never> {
        let allIncrements = calculateIncrements(currentDate: currentDate)
        let lastCheckDate = allIncrements.checkDate
        let increments = allIncrements.increments
        
        return Publishers.Sequence<[AnyPublisher<Void, Never>], Never>(
            sequence: increments.map { increment in
                self.client.getExposureKeys(for: increment)
                    .map { _ in }
                    .replaceError(with: ())
                    .eraseToAnyPublisher()
            })
            .flatMap { $0 }
            .handleEvents(receiveCompletion: { completion in
                if case .finished = completion {
                    self.exposureDetectionStore.save(lastKeyDownloadDate: lastCheckDate)
                    sendFakeExposureWindows()
                }
            })
            .map { _ in nil }
            .ensureFinishes(placeholder: nil)
            .eraseToAnyPublisher()
    }
    
    func detectionMatchesCheckFrequency(currentDate: Date) -> Bool {
        let checkFrequency = exposureRiskManager.checkFrequency
        let lastCheckDate = exposureDetectionStore.load()?.lastKeyDownloadDate ?? .distantPast
        return lastCheckDate.advanced(by: checkFrequency) < currentDate
    }
    
    private func detectExposures(currentDate: Date, configuration: ExposureDetectionConfiguration) -> AnyPublisher<ExposureRiskInfo?, Never> {
        switch exposureRiskManager.preferredProcessingMode {
        case .bulk:
            return detectExposuresInBulk(currentDate: currentDate, configuration: configuration)
        case .incremental:
            return detectExposuresIncrementally(currentDate: currentDate, configuration: configuration)
        }
    }
    
    // MARK: Bulk
    
    private typealias Increments = (increments: [Increment], checkDate: Date)
    
    private func calculateIncrements(currentDate: Date) -> Increments {
        let oldestDownloadDate = Calendar.utc.date(byAdding: Self.oldestDownloadDate, to: currentDate)!
        var lastCheckDate = exposureDetectionStore.load()?.lastKeyDownloadDate ?? oldestDownloadDate
        var increments = [Increment]()
        
        while let incrementInfo = Increment.nextIncrement(lastCheckDate: lastCheckDate, now: currentDate) {
            lastCheckDate = incrementInfo.checkDate
            increments.append(incrementInfo.increment)
        }
        
        return (increments: increments, checkDate: lastCheckDate)
    }
    
    private func detectExposuresInBulk(currentDate: Date, configuration: ExposureDetectionConfiguration) -> AnyPublisher<ExposureRiskInfo?, Never> {
        let allIncrements = calculateIncrements(currentDate: currentDate)
        let lastCheckDate = allIncrements.checkDate
        let increments = allIncrements.increments
        
        if increments.isEmpty {
            return Empty().eraseToAnyPublisher()
        } else {
            return calculateRiskInfo(with: increments, lastCheckDate: lastCheckDate, configuration: configuration)
        }
    }
    
    private func calculateRiskInfo(with increments: [Increment], lastCheckDate: Date, configuration: ExposureDetectionConfiguration) -> AnyPublisher<ExposureRiskInfo?, Never> {
        collectDiagnosisKeyIncrements(with: increments)
            .flatMap { incs -> AnyPublisher<(ENExposureDetectionSummary, [ZIPManager.Handler]), Error> in
                let handlers = Result<[ZIPManager.Handler], Error>.Publisher(.success(incs.map { $0.1 })).eraseToAnyPublisher()
                let summary = self.controller.detectExposures(
                    configuration: ENExposureConfiguration(from: configuration),
                    diagnosisKeyURLs: incs.flatMap { $0.0 }
                )
                return Publishers.CombineLatest(summary, handlers).eraseToAnyPublisher()
            }
            .flatMap { summary, handler in
                self.exposureRiskManager.riskInfo(for: summary, configuration: configuration)
            }
            .handleEvents(receiveCompletion: { completion in
                if case .finished = completion {
                    self.exposureDetectionStore.save(lastKeyDownloadDate: lastCheckDate)
                }
            })
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
    
    private func collectDiagnosisKeyIncrements(with increments: [Increment]) -> AnyPublisher<[([URL], ZIPManager.Handler)], Error> {
        Publishers.Sequence<[AnyPublisher<([URL], ZIPManager.Handler), Error>], Error>(
            sequence: increments.map { increment in
                self.client.getExposureKeys(for: increment)
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
                    .eraseToAnyPublisher()
            })
            .flatMap { $0 }
            .collect()
            .eraseToAnyPublisher()
    }
    
    // MARK: Incremental
    
    private func detectExposuresIncrementally(currentDate: Date, configuration: ExposureDetectionConfiguration) -> AnyPublisher<ExposureRiskInfo?, Never> {
        var risks: AnyPublisher<ExposureRiskInfo?, Error> = Empty().eraseToAnyPublisher()
        
        let oldestDownloadDate = Calendar.utc.date(byAdding: Self.oldestDownloadDate, to: currentDate)!
        var lastCheckDate = exposureDetectionStore.load()?.lastKeyDownloadDate ?? oldestDownloadDate
        
        while let incrementInfo = Increment.nextIncrement(lastCheckDate: lastCheckDate, now: currentDate) {
            lastCheckDate = incrementInfo.checkDate
            let incrementRisk = riskInfo(for: incrementInfo.increment, configuration: configuration)
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
    
    private func riskInfo(for increment: Increment, configuration: ExposureDetectionConfiguration) -> AnyPublisher<ExposureRiskInfo?, Error> {
        Deferred { () -> AnyPublisher<ExposureRiskInfo?, Error> in
            self.client.getExposureKeys(for: increment)
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
                        configuration: ENExposureConfiguration(from: configuration),
                        diagnosisKeyURLs: urls
                    )
                    
                    return Publishers.CombineLatest(summary, handler).eraseToAnyPublisher()
                }
                .flatMap { summary, handler in
                    self.exposureRiskManager.riskInfo(for: summary, configuration: configuration)
                }
                .eraseToAnyPublisher()
        }.eraseToAnyPublisher()
    }
    
}
