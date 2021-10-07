//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation

public enum ContactCaseOptOutQuestion: Equatable {
    case fullyVaccinated
    case lastDose
    case clinicalTrial
    case medicallyExempt
}

public enum ContactCaseOptOutReason: Equatable {
    case fullyVaccinated
    case medicallyExempt
}

public struct ContactCaseOptOutQuestionnaire {
    
    public enum Resolution: Equatable {
        case notFinished
        case optedOutOfIsolation(ContactCaseOptOutReason, [ContactCaseOptOutQuestion])
        case needToIsolate([ContactCaseOptOutQuestion])
    }
    
    private enum State: Equatable {
        case showQuestions([ContactCaseOptOutQuestion])
        case finishedNoNeedToIsolate(questions: [ContactCaseOptOutQuestion], reason: ContactCaseOptOutReason)
        case finishedWithIsolation([ContactCaseOptOutQuestion])
    }
    
    private let country: DomainProperty<Country>
    
    init(country: DomainProperty<Country>) {
        self.country = country
    }
    
    public func nextQuestion(with answers: [ContactCaseOptOutQuestion: Bool]) -> [ContactCaseOptOutQuestion] {
        let nextState = calculateState(with: answers)
        
        switch nextState {
        case .showQuestions(let questions):
            return questions
        case .finishedNoNeedToIsolate(let questions, _):
            return questions
        case .finishedWithIsolation(let questions):
            return questions
        }
    }
    
    public func getResolution(with answers: [ContactCaseOptOutQuestion: Bool]) -> Resolution {
        let nextState = calculateState(with: answers)
        
        switch nextState {
        case .showQuestions:
            return .notFinished
        case .finishedNoNeedToIsolate(let questions, let reason):
            return .optedOutOfIsolation(reason, questions)
        case .finishedWithIsolation(let questions):
            return .needToIsolate(questions)
        }
    }
    
    private func calculateState(with answers: [ContactCaseOptOutQuestion: Bool]) -> State {
        let fullyVaccinated: Bool? = answers[.fullyVaccinated]
        let lastDose: Bool? = answers[.lastDose]
        let clinicalTrial: Bool? = answers[.clinicalTrial]
        let medicallyExempt: Bool? = answers[.medicallyExempt]
        
        var questions: [ContactCaseOptOutQuestion] = [.fullyVaccinated]
        if let fullyVaccinated = fullyVaccinated {
            if fullyVaccinated {
                questions.append(.lastDose)
                if let lastDose = lastDose {
                    if lastDose {
                        return .finishedNoNeedToIsolate(questions: questions, reason: .fullyVaccinated)
                    } else {
                        questions.append(.clinicalTrial)
                        if let clinicalTrial = clinicalTrial {
                            if clinicalTrial {
                                return .finishedNoNeedToIsolate(questions: questions, reason: .fullyVaccinated)
                            } else {
                                switch country.currentValue {
                                case .wales: return .finishedWithIsolation(questions)
                                case .england:
                                    questions.append(.medicallyExempt)
                                    if let medicallyExempt = medicallyExempt {
                                        if medicallyExempt {
                                            return .finishedNoNeedToIsolate(questions: questions, reason: .medicallyExempt)
                                        } else {
                                            return .finishedWithIsolation(questions)
                                        }
                                    }
                                }
                            }
                        }
                    }
                }
            } else {
                switch country.currentValue {
                case .wales:
                    questions.append(.clinicalTrial)
                    if let clinicalTrial = clinicalTrial {
                        if clinicalTrial {
                            return .finishedNoNeedToIsolate(questions: questions, reason: .fullyVaccinated)
                        } else {
                            return .finishedWithIsolation(questions)
                        }
                    }
                case .england:
                    questions.append(.medicallyExempt)
                    if let medicallyExempt = medicallyExempt {
                        if medicallyExempt {
                            return .finishedNoNeedToIsolate(questions: questions, reason: .medicallyExempt)
                        } else {
                            questions.append(.clinicalTrial)
                            if let clinicalTrial = clinicalTrial {
                                if clinicalTrial {
                                    return .finishedNoNeedToIsolate(questions: questions, reason: .fullyVaccinated)
                                } else {
                                    return .finishedWithIsolation(questions)
                                }
                            }
                        }
                    }
                }
            }
        }
        
        return .showQuestions(questions)
    }
    
}
