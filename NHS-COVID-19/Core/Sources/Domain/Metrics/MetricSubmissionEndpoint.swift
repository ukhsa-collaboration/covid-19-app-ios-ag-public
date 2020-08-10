//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation
import Logging
import MetricKit

struct MetricsInfo {
    var payload: MetricPayload
    var postalDistrict: String
    var recordedMetrics: [Metric: Int]
}

struct MetricSubmissionEndpoint: HTTPEndpoint {
    
    private static let logger = Logger(label: "Metrics")
    
    func request(for info: MetricsInfo) throws -> HTTPRequest {
        let payload = SubmissionPayload(info)
        Self.logger.info("Submitting metrics", metadata: .describing(payload))
        
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        encoder.outputFormatting = .prettyPrinted
        let data = try encoder.encode(payload)
        return .post("/submission/mobile-analytics", body: .json(data))
    }
    
    func parse(_ response: HTTPResponse) throws {}
    
}

private struct SubmissionPayload: Codable {
    struct Period: Codable {
        var startDate: Date
        var endDate: Date
    }
    
    struct Metadata: Codable {
        var postalDistrict: String
        var deviceModel: String
        var operatingSystemVersion: String
        var latestApplicationVersion: String
    }
    
    struct Metrics: Codable {
        // Networking
        var cumulativeWifiUploadBytes = 0
        var cumulativeWifiDownloadBytes = 0
        var cumulativeCellularUploadBytes = 0
        var cumulativeCellularDownloadBytes = 0
        var cumulativeDownloadBytes = 0
        var cumulativeUploadBytes = 0
        
        // Events triggered
        var completedOnboarding = 0
        var checkedIn = 0
        var canceledCheckIn = 0
        var completedQuestionnaireAndStartedIsolation = 0
        var completedQuestionnaireButDidNotStartIsolation = 0
        var receivedPositiveTestResult = 0
        var receivedNegativeTestResult = 0
        var receivedVoidTestResult = 0
        
        // How many times background tasks ran
        var totalBackgroundTasks = 0
        
        // How many times background tasks ran when app was running normally (max: totalBackgroundTasks)
        var runningNormallyBackgroundTick = 0
        
        // Background ticks (max: runningNormallyBackgroundTick)
        var isIsolatingBackgroundTick = 0
        var hasHadRiskyContactBackgroundTick = 0
        var hasSelfDiagnosedPositiveBackgroundTick = 0
        var encounterDetectionPausedBackgroundTick = 0
//        var collectedMetric = 0
    }
    
    var includesMultipleApplicationVersions: Bool
    var analyticsWindow: Period
    var metadata: Metadata
    var metrics: Metrics
    
    init(_ metrics: MetricsInfo) {
        analyticsWindow = Period(
            startDate: metrics.payload.timeStampBegin,
            endDate: metrics.payload.timeStampEnd
        )
        
        metadata = Metadata(
            postalDistrict: metrics.postalDistrict,
            deviceModel: metrics.payload.metaData?.deviceType ?? "",
            operatingSystemVersion: metrics.payload.metaData?.osVersion ?? "",
            latestApplicationVersion: metrics.payload.latestApplicationVersion
        )
        
        includesMultipleApplicationVersions = metrics.payload.includesMultipleApplicationVersions
        
        let networkTransferMetrics = metrics.payload.networkTransferMetrics ?? MXNetworkTransferMetric()
        
        let metricCounts = metrics.payload.metricCounts
        
        self.metrics = mutating(Metrics()) {
            $0.cumulativeWifiUploadBytes = Int(networkTransferMetrics.cumulativeWifiUpload.value(in: .bytes))
            $0.cumulativeWifiDownloadBytes = Int(networkTransferMetrics.cumulativeWifiDownload.value(in: .bytes))
            $0.cumulativeCellularUploadBytes = Int(networkTransferMetrics.cumulativeCellularUpload.value(in: .bytes))
            $0.cumulativeCellularDownloadBytes = Int(networkTransferMetrics.cumulativeCellularDownload.value(in: .bytes))
            $0.cumulativeDownloadBytes = $0.cumulativeWifiDownloadBytes + $0.cumulativeCellularDownloadBytes
            $0.cumulativeUploadBytes = $0.cumulativeWifiUploadBytes + $0.cumulativeCellularUploadBytes
            
            for metric in Metric.allCases {
                $0[keyPath: metric.property] = metrics.recordedMetrics[metric] ?? 0
            }
        }
    }
}

private extension Measurement where UnitType: Dimension {
    
    func value(in unit: UnitType) -> Double {
        converted(to: unit).value
    }
    
}

private extension MetricPayload {
    
    var metricCounts: [String: Int] {
        guard let signpostMetrics = signpostMetrics else { return [:] }
        
        return Dictionary(uniqueKeysWithValues: signpostMetrics.lazy
            .filter { $0.signpostCategory == Metrics.category }
            .map { ($0.signpostName, $0.totalCount) }
        )
    }
    
}

private extension Metric {
    
    var property: WritableKeyPath<SubmissionPayload.Metrics, Int> {
        switch self {
        case .backgroundTasks: return \.totalBackgroundTasks
        case .completedOnboarding: return \.completedOnboarding
        case .checkedIn: return \.checkedIn
        case .deletedLastCheckIn: return \.canceledCheckIn
        case .completedQuestionnaireAndStartedIsolation: return \.completedQuestionnaireAndStartedIsolation
        case .completedQuestionnaireButDidNotStartIsolation: return \.completedQuestionnaireButDidNotStartIsolation
        case .receivedPositiveTestResult: return \.receivedPositiveTestResult
        case .receivedNegativeTestResult: return \.receivedNegativeTestResult
        case .receivedVoidTestResult: return \.receivedVoidTestResult
        case .contactCaseBackgroundTick: return \.hasHadRiskyContactBackgroundTick
        case .indexCaseBackgroundTick: return \.hasSelfDiagnosedPositiveBackgroundTick
        case .isolationBackgroundTick: return \.isIsolatingBackgroundTick
        case .pauseTick: return \.encounterDetectionPausedBackgroundTick
        case .runningNormallyTick: return \.runningNormallyBackgroundTick
        }
    }
    
}
