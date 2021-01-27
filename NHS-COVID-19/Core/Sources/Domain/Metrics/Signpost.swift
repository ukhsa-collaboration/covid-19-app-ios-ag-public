//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

public enum Metric: String, CaseIterable {
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
    case receivedActiveIpcToken
    case haveActiveIpcTokenBackgroundTick
    case selectedIsolationPaymentsButton
    case launchedIsolationPaymentsApplication
    case totalExposureWindowsNotConsideredRisky
    case totalExposureWindowsConsideredRisky
    case hasTestedLFDPositiveBackgroundTick
    case isIsolatingForTestedLFDPositiveBackgroundTick
    
    case receivedPositiveLFDTestResultViaPolling
    case receivedNegativeLFDTestResultViaPolling
    case receivedVoidLFDTestResultViaPolling
    case receivedPositiveLFDTestResultEnteredManually
    case receivedNegativeLFDTestResultEnteredManually
    case receivedVoidLFDTestResultEnteredManually
    
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
        case .receivedActiveIpcToken: return "receivedActiveIpcToken"
        case .haveActiveIpcTokenBackgroundTick: return "haveActiveIpcTokenBackgroundTick"
        case .selectedIsolationPaymentsButton: return "selectedIsolationPaymentsButton"
        case .launchedIsolationPaymentsApplication: return "launchedIsolationPaymentsApplication"
        case .totalExposureWindowsNotConsideredRisky: return "totalExposureWindowsNotConsideredRisky"
        case .totalExposureWindowsConsideredRisky: return "totalExposureWindowsConsideredRisky"
        case .receivedPositiveLFDTestResultViaPolling: return "receivedPositiveLFDTestResultViaPolling"
        case .receivedNegativeLFDTestResultViaPolling: return "receivedNegativeLFDTestResultViaPolling"
        case .receivedVoidLFDTestResultViaPolling: return "receivedVoidLFDTestResultViaPolling"
        case .receivedPositiveLFDTestResultEnteredManually: return "receivedPositiveLFDTestResultEnteredManually"
        case .receivedNegativeLFDTestResultEnteredManually: return "receivedNegativeLFDTestResultEnteredManually"
        case .receivedVoidLFDTestResultEnteredManually: return "receivedVoidLFDTestResultEnteredManually"
        case .hasTestedLFDPositiveBackgroundTick: return "hasTestedLFDPositiveBackgroundTick"
        case .isIsolatingForTestedLFDPositiveBackgroundTick: return "isIsolatingForTestedLFDPositiveBackgroundTick"
        }
    }
    
}

public enum Metrics {
    static let category = "AppMetrics"
    
    static func begin(_ metric: Metric) {
        MetricCollector.record(metric)
    }
    
    static func end(_ metric: Metric) {}
    
    public static func signpost(_ metric: Metric) {
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
    
    static func signpostReceivedFromManual(
        testResult: VirologyTestResult.TestResult,
        testKitType: VirologyTestResult.TestKitType
    ) {
        
        Self.signpostReceived(testResult)
        
        switch testKitType {
        case .rapidResult, .rapidSelfReported:
            switch testResult {
            case .positive:
                signpost(.receivedPositiveLFDTestResultEnteredManually)
            case .negative:
                signpost(.receivedNegativeLFDTestResultEnteredManually)
            case .void:
                signpost(.receivedVoidLFDTestResultEnteredManually)
            }
        case .labResult:
            switch testResult {
            case .positive:
                signpost(.receivedPositiveTestResultEnteredManually)
            case .negative:
                signpost(.receivedNegativeTestResultEnteredManually)
            case .void:
                signpost(.receivedVoidTestResultEnteredManually)
            }
        }
        
    }
    
    static func signpostReceivedViaPolling(
        testResult: VirologyTestResult.TestResult,
        testKitType: VirologyTestResult.TestKitType
    ) {
        
        Self.signpostReceived(testResult)
        
        switch testKitType {
        case .labResult:
            switch testResult {
            case .positive:
                signpost(.receivedPositiveTestResultViaPolling)
            case .negative:
                signpost(.receivedNegativeTestResultViaPolling)
            case .void:
                signpost(.receivedVoidTestResultViaPolling)
            }
        case .rapidResult, .rapidSelfReported:
            switch testResult {
            case .positive:
                signpost(.receivedPositiveLFDTestResultViaPolling)
            case .negative:
                signpost(.receivedNegativeLFDTestResultViaPolling)
            case .void:
                signpost(.receivedVoidLFDTestResultViaPolling)
            }
            
        }
        
    }
    
}
