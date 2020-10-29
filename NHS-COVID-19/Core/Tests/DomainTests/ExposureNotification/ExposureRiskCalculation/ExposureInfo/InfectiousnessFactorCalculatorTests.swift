//
// Copyright © 2020 NHSX. All rights reserved.
//

import ExposureNotification
import XCTest
@testable import Domain

class InfectiousnessFactorCalculatorTests: XCTestCase {
    func testParameterisedInfectiousnessFactor() {
        let calc = InfectiousnessFactorCalculator()
        let parameters = [
            (0, 1.0),
            (1, 0.9360225578954148),
            (2, 0.7676181961208854),
            (3, 0.5515397744971644),
            (4, 0.3472010612276297),
            (5, 0.19149519501466308),
            (6, 0.09253528115842204),
            (7, 0.03917684398136177),
        ]
        
        parameters.forEach { daysFromOnset, infectiousnessFactor in
            XCTAssertEqual(
                infectiousnessFactor,
                calc.infectiousnessFactor(for: daysFromOnset)
            )
        }
    }
}
