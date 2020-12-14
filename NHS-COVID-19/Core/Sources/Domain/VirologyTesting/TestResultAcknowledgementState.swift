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
    case neededForPositiveResultStartToIsolate(PositiveResultAcknowledgement, isolationEndDate: Date)
    case neededForPositiveResultContinueToIsolate(PositiveResultAcknowledgement, isolationEndDate: Date)
    case neededForPositiveResultNotIsolating(PositiveResultAcknowledgement)
    case neededForVoidResultContinueToIsolate(acknowledge: () -> Void, isolationEndDate: Date)
    case neededForVoidResultNotIsolating(acknowledge: () -> Void)
    
    public struct PositiveResultAcknowledgement {
        public var acknowledge: () -> AnyPublisher<Void, Error>
        public var acknowledgeWithoutSending: () -> Void
    }
    
    public static func neededForPositiveResult(acknowledge: @escaping () -> AnyPublisher<Void, Error>, isolationEndDate: Date) -> Self {
        .neededForPositiveResultContinueToIsolate(PositiveResultAcknowledgement(acknowledge: acknowledge, acknowledgeWithoutSending: {}), isolationEndDate: isolationEndDate)
    }
    
    public static func neededForPositiveResultNoIsolation(acknowledge: @escaping () -> AnyPublisher<Void, Error>) -> Self {
        .neededForPositiveResultNotIsolating(PositiveResultAcknowledgement(acknowledge: acknowledge, acknowledgeWithoutSending: {}))
    }
    
    public enum SendKeysState {
        case sent
        case notSent
    }
    
    typealias PositiveAcknowledgement = (DiagnosisKeySubmissionToken, Date?, IndexCaseInfo?, @escaping (SendKeysState) -> Void) -> TestResultAcknowledgementState.PositiveResultAcknowledgement
    
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
            guard let diagnosisKeySubmissionToken = result.diagnosisKeySubmissionToken else {
                self = TestResultAcknowledgementState.notNeeded
                return
            }
            self = TestResultAcknowledgementState.neededForPositiveResultContinueToIsolate(
                positiveAcknowledgement(
                    diagnosisKeySubmissionToken,
                    isolation.endDate,
                    indexCaseInfo,
                    completionHandler
                ),
                isolationEndDate: isolation.endDate
            )
        case (.positive, .isolating(let isolation, _, _)):
            guard let diagnosisKeySubmissionToken = result.diagnosisKeySubmissionToken else {
                self = TestResultAcknowledgementState.notNeeded
                return
            }
            
            self = TestResultAcknowledgementState.neededForPositiveResultStartToIsolate(
                positiveAcknowledgement(
                    diagnosisKeySubmissionToken,
                    isolation.endDate,
                    indexCaseInfo,
                    completionHandler
                ),
                isolationEndDate: isolation.endDate
            )
        case (.positive, _):
            guard let diagnosisKeySubmissionToken = result.diagnosisKeySubmissionToken else {
                self = TestResultAcknowledgementState.notNeeded
                return
            }
            let endDate = newIsolationState.isolation?.endDate
            self = TestResultAcknowledgementState.neededForPositiveResultNotIsolating(
                positiveAcknowledgement(
                    diagnosisKeySubmissionToken,
                    endDate,
                    indexCaseInfo,
                    completionHandler
                )
            )
        case (.negative, .isolating(let isolation, _, _)) where isolation.reason == .indexCase(hasPositiveTestResult: true, isSelfDiagnosed: false):
            fallthrough
        case (.negative, .isolating(let isolation, _, _)) where isolation.reason == .indexCase(hasPositiveTestResult: true, isSelfDiagnosed: true):
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
