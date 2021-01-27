//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Foundation

public enum TestResultAcknowledgementState {
    case notNeeded
    case neededForNegativeResultContinueToIsolate(acknowledge: () -> Void, isolationEndDate: Date)
    case neededForNegativeResultNotIsolating(acknowledge: () -> Void)
    case neededForNegativeAfterPositiveResultContinueToIsolate(acknowledge: () -> Void, isolationEndDate: Date)
    case neededForPositiveResultStartToIsolate(PositiveResultAcknowledgement, isolationEndDate: Date, keySubmissionSupported: Bool)
    case neededForPositiveResultContinueToIsolate(PositiveResultAcknowledgement, isolationEndDate: Date, keySubmissionSupported: Bool)
    case neededForPositiveResultNotIsolating(PositiveResultAcknowledgement, keySubmissionSupported: Bool)
    case neededForVoidResultContinueToIsolate(acknowledge: () -> Void, isolationEndDate: Date)
    case neededForVoidResultNotIsolating(acknowledge: () -> Void)
    
    public struct PositiveResultAcknowledgement {
        public var acknowledge: () -> AnyPublisher<Void, Error>
        public var acknowledgeWithoutSending: () -> Void
    }
    
    public static func neededForPositiveResult(acknowledge: @escaping () -> AnyPublisher<Void, Error>, isolationEndDate: Date, keySubmissionSupported: Bool) -> Self {
        .neededForPositiveResultContinueToIsolate(PositiveResultAcknowledgement(acknowledge: acknowledge, acknowledgeWithoutSending: {}), isolationEndDate: isolationEndDate, keySubmissionSupported: keySubmissionSupported)
    }
    
    public static func neededForPositiveResultNoIsolation(acknowledge: @escaping () -> AnyPublisher<Void, Error>, keySubmissionSupported: Bool) -> Self {
        .neededForPositiveResultNotIsolating(PositiveResultAcknowledgement(acknowledge: acknowledge, acknowledgeWithoutSending: {}), keySubmissionSupported: keySubmissionSupported)
    }
    
    public enum SendKeysState {
        case sent
        case notSent
    }
    
    typealias PositiveAcknowledgement = (DiagnosisKeySubmissionToken?, Date?, IndexCaseInfo?, @escaping (SendKeysState) -> Void) -> TestResultAcknowledgementState.PositiveResultAcknowledgement
    
    init(
        result: VirologyStateTestResult,
        newIsolationState: IsolationLogicalState,
        currentIsolationState: IsolationLogicalState,
        indexCaseInfo: IndexCaseInfo?,
        positiveAcknowledgement: PositiveAcknowledgement,
        completionHandler: @escaping (SendKeysState) -> Void
    ) {
        switch (result.testResult, newIsolationState) {
        case (.positive, .isolating(let isolation, _, _)) where currentIsolationState.isIsolating == true:
            self = TestResultAcknowledgementState.neededForPositiveResultContinueToIsolate(
                positiveAcknowledgement(
                    result.diagnosisKeySubmissionToken,
                    isolation.endDate,
                    indexCaseInfo,
                    completionHandler
                ),
                isolationEndDate: isolation.endDate,
                keySubmissionSupported: result.diagnosisKeySubmissionToken != nil
            )
        case (.positive, .isolating(let isolation, _, _)):
            self = TestResultAcknowledgementState.neededForPositiveResultStartToIsolate(
                positiveAcknowledgement(
                    result.diagnosisKeySubmissionToken,
                    isolation.endDate,
                    indexCaseInfo,
                    completionHandler
                ),
                isolationEndDate: isolation.endDate,
                keySubmissionSupported: result.diagnosisKeySubmissionToken != nil
            )
        case (.positive, _):
            let endDate = newIsolationState.isolation?.endDate
            self = TestResultAcknowledgementState.neededForPositiveResultNotIsolating(
                positiveAcknowledgement(
                    result.diagnosisKeySubmissionToken,
                    endDate,
                    indexCaseInfo,
                    completionHandler
                ),
                keySubmissionSupported: result.diagnosisKeySubmissionToken != nil
            )
        case (.negative, .isolating(let isolation, _, _)) where isolation.isIndexCaseOnlyWithPositiveTest:
            self = TestResultAcknowledgementState.neededForNegativeAfterPositiveResultContinueToIsolate(
                acknowledge: { completionHandler(.notSent) },
                isolationEndDate: isolation.endDate
            )
        case (.negative, .isolating(let isolation, _, _)):
            self = TestResultAcknowledgementState.neededForNegativeResultContinueToIsolate(
                acknowledge: { completionHandler(.notSent) },
                isolationEndDate: isolation.endDate
            )
        case (.negative, .notIsolating):
            self = TestResultAcknowledgementState.neededForNegativeResultNotIsolating(
                acknowledge: { completionHandler(.notSent) }
            )
        case (.negative, .isolationFinishedButNotAcknowledged):
            self = TestResultAcknowledgementState.neededForNegativeResultNotIsolating(
                acknowledge: { completionHandler(.notSent) }
            )
        case (.void, .isolating(let isolation, _, _)):
            self = TestResultAcknowledgementState.neededForVoidResultContinueToIsolate(
                acknowledge: { completionHandler(.notSent) },
                isolationEndDate: isolation.endDate
            )
        case (.void, _):
            self = TestResultAcknowledgementState.neededForVoidResultNotIsolating(
                acknowledge: { completionHandler(.notSent) }
            )
        }
    }
    
}
