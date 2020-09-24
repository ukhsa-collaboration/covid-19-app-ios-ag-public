//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import MetricKit

enum Metric: String, CaseIterable {
    case backgroundTasks
    case completedOnboarding
    case checkedIn
    case deletedLastCheckIn
    case completedQuestionnaireAndStartedIsolation
    case completedQuestionnaireButDidNotStartIsolation
    case receivedPositiveTestResult
    case receivedNegativeTestResult
    case receivedVoidTestResult
    case contactCaseBackgroundTick
    case indexCaseBackgroundTick
    case isolationBackgroundTick
    case pauseTick
    case runningNormallyTick
    
    var name: StaticString {
        switch self {
        case .backgroundTasks: return "backgroundTasks"
        case .completedOnboarding: return "completedOnboarding"
        case .checkedIn: return "checkedIn"
        case .deletedLastCheckIn: return "deletedLastCheckIn"
        case .completedQuestionnaireAndStartedIsolation: return "completedQuestionnaireAndStartedIsolation"
        case .completedQuestionnaireButDidNotStartIsolation: return "completedQuestionnaireButDidNotStartIsolation"
        case .receivedPositiveTestResult: return "receivedPositiveTestResult"
        case .receivedNegativeTestResult: return "receivedNegativeTestResult"
        case .receivedVoidTestResult: return "receivedVoidTestResult"
        case .contactCaseBackgroundTick: return "contactCaseBackgroundTick"
        case .indexCaseBackgroundTick: return "indexCaseBackgroundTick"
        case .isolationBackgroundTick: return "isolationBackgroundTick"
        case .pauseTick: return "pauseTick"
        case .runningNormallyTick: return "runningNormallyTick"
        }
    }
    
}

enum Metrics {
    static let category = "AppMetrics"
    
    private static let metricsLogHandle = MXMetricManager.makeLogHandle(category: category)
    
    static func begin(_ metric: Metric) {
        mxSignpost(.begin, log: metricsLogHandle, name: metric.name)
        MetricCollector.record(metric)
    }
    
    static func end(_ metric: Metric) {
        mxSignpost(.end, log: metricsLogHandle, name: metric.name)
    }
    
    static func signpost(_ metric: Metric) {
        MetricCollector.record(metric)
        mxSignpost(.begin, log: metricsLogHandle, name: metric.name)
        mxSignpost(.end, log: metricsLogHandle, name: metric.name)
    }
    
    static func signpostReceived(_ testResult: VirologyTestResult.TestResult) {
        switch testResult {
        case .positive:
            signpost(.receivedPositiveTestResult)
        case .negative:
            signpost(.receivedNegativeTestResult)
        case .void:
            signpost(.receivedVoidTestResult)
        }
    }
}
