//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation
@testable import Domain

struct Questionnaire {
    let manager: SelfDiagnosisManaging
    
    init(context: RunningAppContext) {
        manager = context.selfDiagnosisManager
    }
    
    func selfDiagnosePositive(onsetDay: GregorianDay) throws {
        _ = manager.evaluateSymptoms(symptoms: riskySymptoms, onsetDay: onsetDay, threshold: 0.5)
    }
}

private let riskySymptoms = [(Symptom(title: [:], description: [:], riskWeight: 1.0), true)]
