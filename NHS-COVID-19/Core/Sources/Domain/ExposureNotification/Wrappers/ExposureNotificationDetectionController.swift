//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import ExposureNotification
import Logging

public class ExposureNotificationDetectionController {
    
    private static let logger = Logger(label: "ExposureNotification")
    
    private let manager: ExposureNotificationManaging
    
    public init(manager: ExposureNotificationManaging) {
        self.manager = manager
    }
    
    public func detectExposures(
        configuration: ENExposureConfiguration,
        diagnosisKeyURLs: [URL]
    ) -> AnyPublisher<ENExposureDetectionSummary, Error> {
        Future { [weak self] promise in
            Self.logger.debug("detecting exposures from \(diagnosisKeyURLs.count / 2) batches")
            self?.manager.detectExposures(configuration: configuration, diagnosisKeyURLs: diagnosisKeyURLs) { summary, error in
                if let error = error {
                    Self.logger.info("detecting exposure failed", metadata: .describing(error))
                    promise(.failure(error))
                }
                if let summary = summary {
                    Self.logger.debug("received summary", metadata: .describing(summary))
                    promise(.success(summary))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    public func getExposureInfo(
        summary: ENExposureDetectionSummary
    ) -> AnyPublisher<[ENExposureInfo], Error> {
        Future { [weak self] promise in
            Self.logger.debug("getting exposure info")
            self?.manager.getExposureInfo(summary: summary) { info, error in
                if let error = error {
                    Self.logger.info("getting exposure info failed", metadata: .describing(error))
                    promise(.failure(error))
                }
                if let info = info {
                    Self.logger.debug("received exposure info", metadata: .describing(info))
                    promise(.success(info))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    @available(iOS 13.7, *)
    public func getExposureWindows(
        summary: ENExposureDetectionSummary
    ) -> AnyPublisher<[ENExposureWindow], Error> {
        Future { [weak self] promise in
            Self.logger.debug("getting exposure windows")
            self?.manager.getExposureWindows(summary: summary) { windows, error in
                if let error = error {
                    Self.logger.info("getting exposure windows failed", metadata: .describing(error))
                    promise(.failure(error))
                }
                if let windows = windows {
                    Self.logger.debug("received exposure windows", metadata: .describing(windows))
                    promise(.success(windows))
                }
            }
        }.eraseToAnyPublisher()
    }
    
    public func getDiagnosisKeys() -> AnyPublisher<[ENTemporaryExposureKey], Error> {
        Future { [weak self] promise in
            Self.logger.debug("getting diagnosis keys")
            self?.manager.getDiagnosisKeys { keys, error in
                if let error = error {
                    Self.logger.info("getting diagnosis keys failed", metadata: .describing(error))
                    promise(.failure(error))
                }
                if let keys = keys {
                    Self.logger.debug("received diagnosis keys", metadata: .describing(keys))
                    promise(.success(keys))
                }
            }
        }.eraseToAnyPublisher()
    }
}
