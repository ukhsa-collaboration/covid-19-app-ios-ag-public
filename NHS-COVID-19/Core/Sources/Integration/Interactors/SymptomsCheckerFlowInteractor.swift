//
// Copyright © 2022 DHSC. All rights reserved.
//

import Combine
import Common
import Domain
import Foundation
import Interface
import Localization

struct SymptomsCheckerFlowInteractor: SymptomCheckerFlowViewController.Interacting {
    let symptomsCheckerManager: SymptomsCheckerManaging
    let symptomMapper = SymptomMapping()
    
    func fetchQuestionnaire() -> AnyPublisher<InterfaceSymptomsQuestionnaire, Error> {
        symptomsCheckerManager.fetchQuestionnaire()
            .map { questionnaire in
                let symptomInfos: [SymptomInfo] = questionnaire.symptoms.map { symptom in
                    self.symptomMapper.interfaceSymptomFrom(domainSymptom: symptom)
                }
               
                let cardinalInfo = CardinalSymptomInfo(heading: questionnaire.cardinal.title.localizedString())
                
                let nonCardinalContent = questionnaire.noncardinal.description.localizedString()
                    .split(separator: "\n", omittingEmptySubsequences: true)
                    .map(String.init)
                
                let nonCardinalInfo = CardinalSymptomInfo(
                    heading: questionnaire.noncardinal.title.localizedString(),
                    content: nonCardinalContent
                )

                return InterfaceSymptomsQuestionnaire(
                    riskThreshold: questionnaire.riskThreshold,
                    symptoms: symptomInfos,
                    cardinal: cardinalInfo,
                    noncardinal: nonCardinalInfo,
                    dateSelectionWindow: questionnaire.dateSelectionWindow
                )
            }
            .mapError { $0 }
            .eraseToAnyPublisher()
    }
    
    func invoke(interfaceSymptomsQuestionnaire: InterfaceSymptomsQuestionnaire?, isFeelingWell: Bool?) -> SymptomaticSummaryResult? {
        let symptomCheckerQuestions = SymptomCheckerQuestions(
            hasNonCardinalSymptoms: interfaceSymptomsQuestionnaire?.noncardinal.hasSymptoms,
            hasCardinalSymptoms: interfaceSymptomsQuestionnaire?.cardinal.hasSymptoms,
            isFeelingWell: isFeelingWell
            )
        
        if let symptomaticSummaryResult = symptomsCheckerManager.invoke(symptomCheckerQuestions: symptomCheckerQuestions) {
            switch symptomaticSummaryResult {
            case .tryToStayAtHome:
                return .tryStayHome
            case .continueNormalActivities:
                return .continueWithNormalActivities
            }
        }
        
        return nil
    }

    func store(shouldTryToStayAtHome: Bool) {
        symptomsCheckerManager.store(shouldTryToStayAtHome: shouldTryToStayAtHome)
    }
}
