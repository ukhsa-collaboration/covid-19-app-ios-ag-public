//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

protocol InfectiousnessFactorCalculating {
    func infectiousnessFactor(for daysFromOnset: Int) -> Double
}

struct InfectiousnessFactorCalculator: InfectiousnessFactorCalculating {
    private static let sigma = 2.75

    // Calculated using equation 3 from the paper at https://arxiv.org/pdf/2005.11057.pdf
    func infectiousnessFactor(for daysFromOnset: Int) -> Double {
        let step1 = Double(daysFromOnset) / Self.sigma
        let step2 = pow(step1, 2)
        let step3 = -0.5 * step2
        return exp(step3)
    }
}
