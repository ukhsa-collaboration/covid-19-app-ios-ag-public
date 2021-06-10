//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Foundation

public enum TestResultAcknowledgementState {
    case notNeeded
    case askForSymptomsOnsetDay(testEndDay: GregorianDay, didFinishAskForSymptomsOnsetDay: () -> Void, didConfirmSymptoms: () -> Void, setOnsetDay: (GregorianDay) -> Void)
    case neededForNegativeResultContinueToIsolate(acknowledge: () -> Void, isolationEndDate: Date)
    case neededForNegativeResultNotIsolating(acknowledge: () -> Void)
    case neededForNegativeAfterPositiveResultContinueToIsolate(acknowledge: () -> Void, isolationEndDate: Date)
    case neededForPositiveResultStartToIsolate(acknowledge: () -> Void, isolationEndDate: Date)
    case neededForPositiveResultContinueToIsolate(acknowledge: () -> Void, isolationEndDate: Date, requiresConfirmatoryTest: Bool)
    case neededForPositiveResultNotIsolating(acknowledge: () -> Void)
    case neededForVoidResultContinueToIsolate(acknowledge: () -> Void, isolationEndDate: Date)
    case neededForVoidResultNotIsolating(acknowledge: () -> Void)
    case neededForPlodResult(acknowledge: () -> Void)
    case neededForUnknownResult(acknowledge: () -> Void, openAppStore: () -> Void)
    
    init(
        result: VirologyStateTestResult,
        newIsolationState: IsolationLogicalState,
        currentIsolationState: IsolationLogicalState,
        indexCaseInfo: IndexCaseInfo?,
        completionHandler: @escaping () -> Void
    ) {
        switch (result.testResult, newIsolationState) {
        case (.positive, .isolating(let isolation, _, _)) where currentIsolationState.isIsolating == true:
            self = TestResultAcknowledgementState.neededForPositiveResultContinueToIsolate(
                acknowledge: completionHandler,
                isolationEndDate: isolation.endDate,
                requiresConfirmatoryTest: result.requiresConfirmatoryTest
            )
        case (.positive, .isolating(let isolation, _, _)):
            self = TestResultAcknowledgementState.neededForPositiveResultStartToIsolate(
                acknowledge: completionHandler,
                isolationEndDate: isolation.endDate
            )
        case (.positive, _):
            self = TestResultAcknowledgementState.neededForPositiveResultNotIsolating(
                acknowledge: completionHandler
            )
        case (.negative, .isolating(let isolation, _, _))
            where isolation.hasPositiveTestResult || isolation.isSelfDiagnosed:
            self = TestResultAcknowledgementState.neededForNegativeAfterPositiveResultContinueToIsolate(
                acknowledge: completionHandler,
                isolationEndDate: isolation.endDate
            )
        case (.negative, .isolating(let isolation, _, _)):
            self = TestResultAcknowledgementState.neededForNegativeResultContinueToIsolate(
                acknowledge: completionHandler,
                isolationEndDate: isolation.endDate
            )
        case (.negative, .notIsolating):
            self = TestResultAcknowledgementState.neededForNegativeResultNotIsolating(
                acknowledge: completionHandler
            )
        case (.negative, .isolationFinishedButNotAcknowledged):
            self = TestResultAcknowledgementState.neededForNegativeResultNotIsolating(
                acknowledge: completionHandler
            )
        case (.void, .isolating(let isolation, _, _)):
            self = TestResultAcknowledgementState.neededForVoidResultContinueToIsolate(
                acknowledge: completionHandler,
                isolationEndDate: isolation.endDate
            )
        case (.void, _):
            self = TestResultAcknowledgementState.neededForVoidResultNotIsolating(
                acknowledge: completionHandler
            )
        case (.plod, _):
            self = TestResultAcknowledgementState.neededForPlodResult(
                acknowledge: completionHandler
            )
        }
    }
}
