//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

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
    case selfDiagnosedBackgroundTick
    case testedPositiveBackgroundTick
    case isolatedForSelfDiagnosedBackgroundTick
    case isolatedForTestedPositiveBackgroundTick
    case isolatedForHadRiskyContactBackgroundTick
    case indexCaseBackgroundTick
    case isolationBackgroundTick
    case pauseTick
    case runningNormallyTick
    case receivedVoidTestResultEnteredManually
    case receivedPositiveTestResultEnteredManually
    case receivedNegativeTestResultEnteredManually
    case receivedVoidTestResultViaPolling
    case receivedPositiveTestResultViaPolling
    case receivedNegativeTestResultViaPolling
    case receivedRiskyContactNotification
    case startedIsolation
    
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
        case .receivedVoidTestResultEnteredManually: return "receivedVoidTestResultEnteredManually"
        case .receivedPositiveTestResultEnteredManually: return "receivedPositiveTestResultEnteredManually"
        case .receivedNegativeTestResultEnteredManually: return "receivedNegativeTestResultEnteredManually"
        case .receivedVoidTestResultViaPolling: return "receivedVoidTestResultViaPolling"
        case .receivedPositiveTestResultViaPolling: return "receivedPositiveTestResultViaPolling"
        case .receivedNegativeTestResultViaPolling: return "receivedNegativeTestResultViaPolling"
        case .selfDiagnosedBackgroundTick: return "selfDiagnosedBackgroundTick"
        case .testedPositiveBackgroundTick: return "testedPositiveBackgroundTick"
        case .isolatedForSelfDiagnosedBackgroundTick: return "isolatedForSelfDiagnosedBackgroundTick"
        case .isolatedForTestedPositiveBackgroundTick: return "isolatedForTestedPositiveBackgroundTick"
        case .isolatedForHadRiskyContactBackgroundTick: return "isolatedForHadRiskyContactBackgroundTick"
        case .receivedRiskyContactNotification: return "receivedRiskyContactNotification"
        case .startedIsolation: return "startedIsolation"
        }
    }
    
}

enum Metrics {
    static let category = "AppMetrics"
    
    static func begin(_ metric: Metric) {
        MetricCollector.record(metric)
    }
    
    static func end(_ metric: Metric) {}
    
    static func signpost(_ metric: Metric) {
        MetricCollector.record(metric)
    }
    
    private static func signpostReceived(_ testResult: VirologyTestResult.TestResult) {
        switch testResult {
        case .positive:
            signpost(.receivedPositiveTestResult)
        case .negative:
            signpost(.receivedNegativeTestResult)
        case .void:
            signpost(.receivedVoidTestResult)
        }
    }
    
    static func signpostReceivedFromManual(testResult: VirologyTestResult.TestResult) {
        
        Self.signpostReceived(testResult)
        
        switch testResult {
        case .positive:
            signpost(.receivedPositiveTestResultEnteredManually)
        case .negative:
            signpost(.receivedNegativeTestResultEnteredManually)
        case .void:
            signpost(.receivedVoidTestResultEnteredManually)
        }
    }
    
    static func signpostReceivedViaPolling(testResult: VirologyTestResult.TestResult) {
        
        Self.signpostReceived(testResult)
        
        switch testResult {
        case .positive:
            signpost(.receivedPositiveTestResultViaPolling)
        case .negative:
            signpost(.receivedNegativeTestResultViaPolling)
        case .void:
            signpost(.receivedVoidTestResultViaPolling)
        }
    }
    
}
