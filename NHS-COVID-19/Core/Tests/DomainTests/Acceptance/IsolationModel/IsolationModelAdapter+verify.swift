//
// Copyright © 2021 DHSC. All rights reserved.
//

import BehaviourModels
import Domain
import Foundation

extension IsolationModelAdapter {
    
    func verify(_ context: RunningAppContext, isIn logicalState: IsolationModel.State) throws {
        let expected = try expectedState(for: logicalState)
        let actual = context.isolationState.currentValue
        switch (expected, actual) {
        case (.noNeedToIsolate(let lhs), .noNeedToIsolate(let rhs)):
            guard lhs == rhs else {
                throw IsolationModelAcceptanceError("Expected opt out of isolation date to be \(String(describing: lhs)). Instead it is \(String(describing: rhs))")
            }
        case (.isolate(let lhs), .isolate(let rhs)):
            guard lhs.reason == rhs.reason else {
                throw IsolationModelAcceptanceError("Expected isolation reason to be \(lhs.reason). Instead it is \(rhs.reason)")
            }
            guard lhs.optOutOfContactIsolationInfo == rhs.optOutOfContactIsolationInfo else {
                throw IsolationModelAcceptanceError("When isolation, expected opt out of isolation to be \(String(describing: lhs.optOutOfContactIsolationInfo)). Instead it is \(String(describing: rhs.optOutOfContactIsolationInfo))")
            }
        case (.noNeedToIsolate, .isolate(let payload)):
            throw IsolationModelAcceptanceError("Expected to not be in isolation but instead it is isolating with \(payload.reason)")
        case (.isolate(let payload), .noNeedToIsolate):
            throw IsolationModelAcceptanceError("Expected to be isolating with \(payload.reason) but instead it is not isolating")
        }
    }
    
    func canDistinguish(_ lhs: IsolationModel.State, from rhs: IsolationModel.State) -> Bool {
        do {
            return try expectedState(for: lhs) != expectedState(for: rhs)
        } catch {
            return false
        }
    }
    
    private func expectedState(for logicalState: IsolationModel.State) throws -> IsolationState {
        switch (logicalState.contact, logicalState.symptomatic, logicalState.positiveTest) {
        case (.noIsolation, .noIsolation, .noIsolation):
            return .noNeedToIsolate(optOutOfIsolationDay: nil)
        // 3 (.*, .noIsolation, .noIsolation)
        case (.isolating, .noIsolation, .noIsolation):
            return .isolate(contactCaseIsolation)
        case (.notIsolatingAndHadRiskyContactPreviously, .noIsolation, .noIsolation):
            return .noNeedToIsolate(optOutOfIsolationDay: nil)
        case (.notIsolatingAndHadRiskyContactIsolationTerminatedEarly, .noIsolation, .noIsolation):
            return .noNeedToIsolate(optOutOfIsolationDay: contactCase.optedOutIsolationDate)
        // 3 (.noIsolation, .*, .noIsolation)
        case (.noIsolation, .isolating, .noIsolation):
            return .isolate(indexCaseIsolation())
        case (.noIsolation, .notIsolatingAndHadSymptomsPreviously, .noIsolation):
            return .noNeedToIsolate(optOutOfIsolationDay: nil)
        // 5 (.noIsolation, .noIsolation, .*)
        case (.noIsolation, .noIsolation, .isolatingWithConfirmedTest):
            return .isolate(indexCasePositiveTestIsolation())
        case (.noIsolation, .noIsolation, .isolatingWithUnconfirmedTest):
            return .isolate(indexCasePositiveTestIsolation(isPendingConfirmation: true))
        case (.noIsolation, .noIsolation, .notIsolatingAndHadConfirmedTestPreviously):
            return .noNeedToIsolate(optOutOfIsolationDay: nil)
        case (.noIsolation, .noIsolation, .notIsolatingAndHadUnconfirmedTestPreviously):
            return .noNeedToIsolate(optOutOfIsolationDay: nil)
        case (.noIsolation, .noIsolation, .notIsolatingAndHasNegativeTest):
            return .noNeedToIsolate(optOutOfIsolationDay: nil)
        // 5 (.noIsolation, .isolating, *)
        case (.noIsolation, .isolating, .isolatingWithConfirmedTest):
            return .isolate(indexCasePositiveTestIsolation(isSelfDiagnosed: true))
        case (.noIsolation, .isolating, .isolatingWithUnconfirmedTest):
            return .isolate(indexCasePositiveTestIsolation(isPendingConfirmation: true, isSelfDiagnosed: true))
        case (.noIsolation, .isolating, .notIsolatingAndHadConfirmedTestPreviously):
            throw IsolationModelAcceptanceError.forbidden
        case (.noIsolation, .isolating, .notIsolatingAndHadUnconfirmedTestPreviously):
            throw IsolationModelAcceptanceError.forbidden
        case (.noIsolation, .isolating, .notIsolatingAndHasNegativeTest):
            throw IsolationModelAcceptanceError.forbidden
        // 5 (.noIsolation, .notIsolatingAndHadSymptomsPreviously, *)
        case (.noIsolation, .notIsolatingAndHadSymptomsPreviously, .isolatingWithConfirmedTest):
            throw IsolationModelAcceptanceError.forbidden
        case (.noIsolation, .notIsolatingAndHadSymptomsPreviously, .isolatingWithUnconfirmedTest):
            throw IsolationModelAcceptanceError.forbidden
        case (.noIsolation, .notIsolatingAndHadSymptomsPreviously, .notIsolatingAndHadConfirmedTestPreviously):
            return .noNeedToIsolate(optOutOfIsolationDay: nil)
        case (.noIsolation, .notIsolatingAndHadSymptomsPreviously, .notIsolatingAndHadUnconfirmedTestPreviously):
            return .noNeedToIsolate(optOutOfIsolationDay: nil)
        case (.noIsolation, .notIsolatingAndHadSymptomsPreviously, .notIsolatingAndHasNegativeTest):
            return .noNeedToIsolate(optOutOfIsolationDay: nil)
        // 3 (*, .isolating, .noIsolation)
        case (.isolating, .isolating, .noIsolation):
            return .isolate(bothCasesIsolation())
        case (.notIsolatingAndHadRiskyContactPreviously, .isolating, .noIsolation):
            return .isolate(indexCaseIsolation())
        case (.notIsolatingAndHadRiskyContactIsolationTerminatedEarly, .isolating, .noIsolation):
            return .isolate(indexCaseIsolation(optedOutOfContactIsolation: true))
        // 3 (*, .notIsolatingAndHadSymptomsPreviously, .noIsolation)
        case (.isolating, .notIsolatingAndHadSymptomsPreviously, .noIsolation):
            return .isolate(contactCaseIsolation)
        case (.notIsolatingAndHadRiskyContactPreviously, .notIsolatingAndHadSymptomsPreviously, .noIsolation):
            return .noNeedToIsolate(optOutOfIsolationDay: nil)
        case (.notIsolatingAndHadRiskyContactIsolationTerminatedEarly, .notIsolatingAndHadSymptomsPreviously, .noIsolation):
            return .noNeedToIsolate(optOutOfIsolationDay: contactCase.optedOutIsolationDate)
        // 3 (*, .isolating, .isolatingWithConfirmedTest)
        case (.isolating, .isolating, .isolatingWithConfirmedTest):
            throw IsolationModelAcceptanceError.forbidden
        case (.notIsolatingAndHadRiskyContactPreviously, .isolating, .isolatingWithConfirmedTest):
            throw IsolationModelAcceptanceError.forbidden
        case (.notIsolatingAndHadRiskyContactIsolationTerminatedEarly, .isolating, .isolatingWithConfirmedTest):
            throw IsolationModelAcceptanceError.forbidden
        // 3 (*, .isolating, .isolatingWithUnconfirmedTest)
        case (.isolating, .isolating, .isolatingWithUnconfirmedTest):
            return .isolate(bothCasesIsolation(hasPositiveTestResult: true, isPendingConfirmation: true, isSelfDiagnosed: true))
        case (.notIsolatingAndHadRiskyContactPreviously, .isolating, .isolatingWithUnconfirmedTest):
            return .isolate(indexCasePositiveTestIsolation(isPendingConfirmation: true, isSelfDiagnosed: true))
        case (.notIsolatingAndHadRiskyContactIsolationTerminatedEarly, .isolating, .isolatingWithUnconfirmedTest):
            return .isolate(indexCasePositiveTestIsolation(optedOutOfContactIsolation: true, isPendingConfirmation: true, isSelfDiagnosed: true))
        // 3 (*, .isolating, .notIsolatingAndHadConfirmedTestPreviously)
        case (.isolating, .isolating, .notIsolatingAndHadConfirmedTestPreviously):
            throw IsolationModelAcceptanceError.forbidden
        case (.notIsolatingAndHadRiskyContactPreviously, .isolating, .notIsolatingAndHadConfirmedTestPreviously):
            throw IsolationModelAcceptanceError.forbidden
        case (.notIsolatingAndHadRiskyContactIsolationTerminatedEarly, .isolating, .notIsolatingAndHadConfirmedTestPreviously):
            throw IsolationModelAcceptanceError.forbidden
        // 3 (*, .isolating, .notIsolatingAndHadUnconfirmedTestPreviously)
        case (.isolating, .isolating, .notIsolatingAndHadUnconfirmedTestPreviously):
            throw IsolationModelAcceptanceError.forbidden
        case (.notIsolatingAndHadRiskyContactPreviously, .isolating, .notIsolatingAndHadUnconfirmedTestPreviously):
            throw IsolationModelAcceptanceError.forbidden
        case (.notIsolatingAndHadRiskyContactIsolationTerminatedEarly, .isolating, .notIsolatingAndHadUnconfirmedTestPreviously):
            throw IsolationModelAcceptanceError.forbidden
        // 3 (*, .isolating, .notIsolatingAndHasNegativeTest)
        case (.isolating, .isolating, .notIsolatingAndHasNegativeTest):
            throw IsolationModelAcceptanceError.forbidden
        case (.notIsolatingAndHadRiskyContactPreviously, .isolating, .notIsolatingAndHasNegativeTest):
            throw IsolationModelAcceptanceError.forbidden
        case (.notIsolatingAndHadRiskyContactIsolationTerminatedEarly, .isolating, .notIsolatingAndHasNegativeTest):
            throw IsolationModelAcceptanceError.forbidden
        // 3 (*, .notIsolatingAndHadSymptomsPreviously, .isolatingWithConfirmedTest)
        case (.isolating, .notIsolatingAndHadSymptomsPreviously, .isolatingWithConfirmedTest):
            throw IsolationModelAcceptanceError.forbidden
        case (.notIsolatingAndHadRiskyContactPreviously, .notIsolatingAndHadSymptomsPreviously, .isolatingWithConfirmedTest):
            throw IsolationModelAcceptanceError.forbidden
        case (.notIsolatingAndHadRiskyContactIsolationTerminatedEarly, .notIsolatingAndHadSymptomsPreviously, .isolatingWithConfirmedTest):
            throw IsolationModelAcceptanceError.forbidden
        // 3 (*, .notIsolatingAndHadSymptomsPreviously, .isolatingWithUnconfirmedTest)
        case (.isolating, .notIsolatingAndHadSymptomsPreviously, .isolatingWithUnconfirmedTest):
            throw IsolationModelAcceptanceError.forbidden
        case (.notIsolatingAndHadRiskyContactPreviously, .notIsolatingAndHadSymptomsPreviously, .isolatingWithUnconfirmedTest):
            throw IsolationModelAcceptanceError.forbidden
        case (.notIsolatingAndHadRiskyContactIsolationTerminatedEarly, .notIsolatingAndHadSymptomsPreviously, .isolatingWithUnconfirmedTest):
            throw IsolationModelAcceptanceError.forbidden
        // 3 (*, .notIsolatingAndHadSymptomsPreviously, .notIsolatingAndHadConfirmedTestPreviously)
        case (.isolating, .notIsolatingAndHadSymptomsPreviously, .notIsolatingAndHadConfirmedTestPreviously):
            return .isolate(contactCaseIsolation)
        case (.notIsolatingAndHadRiskyContactPreviously, .notIsolatingAndHadSymptomsPreviously, .notIsolatingAndHadConfirmedTestPreviously):
            return .noNeedToIsolate(optOutOfIsolationDay: nil)
        case (.notIsolatingAndHadRiskyContactIsolationTerminatedEarly, .notIsolatingAndHadSymptomsPreviously, .notIsolatingAndHadConfirmedTestPreviously):
            return .noNeedToIsolate(optOutOfIsolationDay: contactCase.optedOutIsolationDate)
        // 3 (*, .isolating, .notIsolatingAndHadUnconfirmedTestPreviously)
        case (.isolating, .notIsolatingAndHadSymptomsPreviously, .notIsolatingAndHadUnconfirmedTestPreviously):
            return .isolate(contactCaseIsolation)
        case (.notIsolatingAndHadRiskyContactPreviously, .notIsolatingAndHadSymptomsPreviously, .notIsolatingAndHadUnconfirmedTestPreviously):
            return .noNeedToIsolate(optOutOfIsolationDay: nil)
        case (.notIsolatingAndHadRiskyContactIsolationTerminatedEarly, .notIsolatingAndHadSymptomsPreviously, .notIsolatingAndHadUnconfirmedTestPreviously):
            return .noNeedToIsolate(optOutOfIsolationDay: contactCase.optedOutIsolationDate)
        // 3 (*, .notIsolatingAndHadSymptomsPreviously, .notIsolatingAndHasNegativeTest)
        case (.isolating, .notIsolatingAndHadSymptomsPreviously, .notIsolatingAndHasNegativeTest):
            return .isolate(contactCaseIsolation)
        case (.notIsolatingAndHadRiskyContactPreviously, .notIsolatingAndHadSymptomsPreviously, .notIsolatingAndHasNegativeTest):
            return .noNeedToIsolate(optOutOfIsolationDay: nil)
        case (.notIsolatingAndHadRiskyContactIsolationTerminatedEarly, .notIsolatingAndHadSymptomsPreviously, .notIsolatingAndHasNegativeTest):
            return .noNeedToIsolate(optOutOfIsolationDay: contactCase.optedOutIsolationDate)
        // 5 (.isolating, .noIsolation, .*)
        case (.isolating, .noIsolation, .isolatingWithConfirmedTest):
            throw IsolationModelAcceptanceError.forbidden
        case (.isolating, .noIsolation, .isolatingWithUnconfirmedTest):
            return .isolate(bothCasesIsolation(hasPositiveTestResult: true, isPendingConfirmation: true, isSelfDiagnosed: false))
        case (.isolating, .noIsolation, .notIsolatingAndHadConfirmedTestPreviously):
            return .isolate(contactCaseIsolation)
        case (.isolating, .noIsolation, .notIsolatingAndHadUnconfirmedTestPreviously):
            return .isolate(contactCaseIsolation)
        case (.isolating, .noIsolation, .notIsolatingAndHasNegativeTest):
            return .isolate(contactCaseIsolation)
        // 5 (.notIsolatingAndHadRiskyContactIsolationTerminatedEarly, .noIsolation, .*)
        case (.notIsolatingAndHadRiskyContactIsolationTerminatedEarly, .noIsolation, .isolatingWithConfirmedTest):
            throw IsolationModelAcceptanceError.forbidden
        case (.notIsolatingAndHadRiskyContactIsolationTerminatedEarly, .noIsolation, .isolatingWithUnconfirmedTest):
            return .isolate(indexCasePositiveTestIsolation(optedOutOfContactIsolation: true, isPendingConfirmation: true))
        case (.notIsolatingAndHadRiskyContactIsolationTerminatedEarly, .noIsolation, .notIsolatingAndHadConfirmedTestPreviously):
            return .noNeedToIsolate(optOutOfIsolationDay: contactCase.optedOutIsolationDate)
        case (.notIsolatingAndHadRiskyContactIsolationTerminatedEarly, .noIsolation, .notIsolatingAndHadUnconfirmedTestPreviously):
            return .noNeedToIsolate(optOutOfIsolationDay: contactCase.optedOutIsolationDate)
        case (.notIsolatingAndHadRiskyContactIsolationTerminatedEarly, .noIsolation, .notIsolatingAndHasNegativeTest):
            return .noNeedToIsolate(optOutOfIsolationDay: contactCase.optedOutIsolationDate)
        // 5 (.notIsolatingAndHadRiskyContactPreviously, .noIsolation, .*)
        case (.notIsolatingAndHadRiskyContactPreviously, .noIsolation, .isolatingWithConfirmedTest):
            throw IsolationModelAcceptanceError.forbidden
        case (.notIsolatingAndHadRiskyContactPreviously, .noIsolation, .isolatingWithUnconfirmedTest):
            return .isolate(indexCasePositiveTestIsolation(isPendingConfirmation: true))
        case (.notIsolatingAndHadRiskyContactPreviously, .noIsolation, .notIsolatingAndHadConfirmedTestPreviously):
            return .noNeedToIsolate(optOutOfIsolationDay: nil)
        case (.notIsolatingAndHadRiskyContactPreviously, .noIsolation, .notIsolatingAndHadUnconfirmedTestPreviously):
            return .noNeedToIsolate(optOutOfIsolationDay: nil)
        case (.notIsolatingAndHadRiskyContactPreviously, .noIsolation, .notIsolatingAndHasNegativeTest):
            return .noNeedToIsolate(optOutOfIsolationDay: nil)
        }
    }
}
