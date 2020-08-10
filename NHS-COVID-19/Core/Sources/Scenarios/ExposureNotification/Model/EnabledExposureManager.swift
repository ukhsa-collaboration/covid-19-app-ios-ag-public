//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import ExposureNotification
import Foundation

/// Methods on this class must only be used if the underlying `ENManager` is already enabled
class EnabledExposureManager {
    
    struct Detection {
        var configuration: ENExposureConfiguration
        var summary: ENExposureDetectionSummary
        var infos: [ENExposureInfo]
    }
    
    enum Mode {
        case normal
        case testing
    }
    
    private let manager: ENManager
    
    private var progress: Progress?
    
    init(manager: ENManager) {
        self.manager = manager
    }
    
    func getDiagnosisKeys(mode: EnabledExposureManager.Mode = .normal, completion: @escaping (Result<[ENTemporaryExposureKey], Error>) -> Void) {
        manager.getDiagnosisKeys(mode: mode) { keys, error in
            if let error = error {
                completion(.failure(error))
            }
            if let keys = keys {
                completion(.success(keys))
            }
        }
    }
    
    func detectExposure(for keys: [ExposureKey], configuration: ENExposureConfiguration, completion: @escaping (Result<String, Error>) -> Void) {
        exposureResult(for: keys, configuration: configuration) { result in
            switch result {
            case .failure(let error):
                completion(.failure(error))
            case .success(let detection):
                guard !detection.infos.isEmpty else {
                    completion(.success("No exposure detected"))
                    return
                }
                let lastExposure = detection.infos.sorted { $0.date < $1.date }.last!
                self.progress?.cancel()
                completion(
                    .success(
                        """
                        \(detection.summary)
                        
                        Last exposure date: \(lastExposure.date)
                        Last exposure duration: \(lastExposure.duration)
                        
                        \(detection.infos)
                        """
                    )
                )
            }
        }
    }
    
    func exposure(to device: ExperimentKeysPayload, configuration: ENExposureConfiguration) -> AnyPublisher<ExperimentResultsPayload, Error> {
        let keys = device.temporaryTracingKeys.map { $0.exposureKey }
        return exposure(for: keys, configuration: configuration)
            .map { detection in
                ExperimentResultsPayload(
                    info: device.info,
                    summary: .init(summary: detection.summary),
                    exposureInfos: detection.infos.map { .init(info: $0) }
                )
            }
            .eraseToAnyPublisher()
    }
    
    func exposure(to participant: Experiment.Participant, configuration: ENExposureConfiguration) -> AnyPublisher<Experiment.DetectionResult, Error> {
        let keys = participant.temporaryTracingKeys.map { $0.exposureKey }
        return exposure(for: keys, configuration: configuration)
            .map { detection in
                Experiment.DetectionResult(
                    deviceName: participant.deviceName,
                    summary: .init(summary: detection.summary),
                    exposureInfos: detection.infos.map { .init(info: $0) }
                )
            }
            .eraseToAnyPublisher()
    }
    
    private let sema = DispatchSemaphore(value: 1)
    
    func exposure(for keys: [ExposureKey], configuration: ENExposureConfiguration) -> AnyPublisher<Detection, Error> {
        Future { observer in
            self.sema.wait()
            self.exposureResult(for: keys, configuration: configuration) {
                observer($0)
                self.sema.signal()
            }
        }.eraseToAnyPublisher()
    }
    
    func exposureResult(for keys: [ExposureKey], configuration: ENExposureConfiguration, completion: @escaping (Result<Detection, Error>) -> Void) {
        let body = TemporaryExposureKeyExport.with {
            $0.startTimestamp = UInt64(Date().timeIntervalSince1970 - 14 * 86400)
            $0.endTimestamp = UInt64(Date().timeIntervalSince1970)
            $0.batchNum = 1
            $0.batchSize = 1
            
            $0.keys = keys.map { key in
                TemporaryExposureKey.with {
                    $0.keyData = key.keyData
                    $0.rollingStartIntervalNumber = Int32(key.rollingStartNumber)
                    $0.rollingPeriod = Int32(key.rollingPeriod)
                    $0.transmissionRiskLevel = Int32(key.transmissionRiskLevel)
                }
            }
        }
        let temp = try! FileManager().url(for: .itemReplacementDirectory, in: .userDomainMask, appropriateFor: Bundle.main.bundleURL, create: true)
        let file = temp.appendingPathComponent(UUID().uuidString) // bin
        
        let header = "EK Export v1    ".data(using: .utf8)!
        try! (header + body.serializedData()).write(to: file)
        
        progress?.cancel()
        progress = manager.detectExposures(configuration: configuration, diagnosisKeyURLs: [file /* , sig */ ]) { summary, error in
            if let error = error {
                completion(.failure(error))
            }
            if let summary = summary {
                self.manager.getExposureInfo(summary: summary, userExplanation: "Verifying exposure info.") { infos, error in
                    if let error = error {
                        completion(.failure(error))
                    }
                    if let infos = infos {
                        let detection = Detection(
                            configuration: configuration,
                            summary: summary,
                            infos: infos
                        )
                        completion(.success(detection))
                    }
                }
            }
        }
    }
    
}

private extension ENManager {
    
    func getDiagnosisKeys(mode: EnabledExposureManager.Mode, completionHandler: @escaping ENGetDiagnosisKeysHandler) {
        switch mode {
        case .normal:
            getDiagnosisKeys(completionHandler: completionHandler)
        case .testing:
            getTestDiagnosisKeys(completionHandler: completionHandler)
        }
    }
    
}
