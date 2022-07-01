//
// Copyright © 2022 DHSC. All rights reserved.
//

import Foundation
import Common

public struct SymptomCheckerQuestions {
    var hasNonCardinalSymptoms: Bool?
    var hasCardinalSymptoms: Bool?
    var isFeelingWell: Bool?

    public init(hasNonCardinalSymptoms: Bool?, hasCardinalSymptoms: Bool?, isFeelingWell: Bool?) {
        self.hasNonCardinalSymptoms = hasNonCardinalSymptoms
        self.hasCardinalSymptoms = hasCardinalSymptoms
        self.isFeelingWell = isFeelingWell
    }
}

public enum SymptomCheckerAdviceResult {
    case tryToStayAtHome
    case continueNormalActivities
}

struct SymptomCheckerAdviceHandler {
    func invoke(symptomCheckerQuestions: SymptomCheckerQuestions) -> SymptomCheckerAdviceResult? {

        guard let hasNonCardinalSymptoms = symptomCheckerQuestions.hasNonCardinalSymptoms,
              let hasCardinalSymptoms = symptomCheckerQuestions.hasCardinalSymptoms,
              let isFeelingWell = symptomCheckerQuestions.isFeelingWell else {
            return nil
        }

        if !hasCardinalSymptoms && isFeelingWell {
            return .continueNormalActivities
        } else {
            return .tryToStayAtHome
        }
    }
}
