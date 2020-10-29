//
// Copyright © 2020 NHSX. All rights reserved.
//

import ExposureNotification
import XCTest
import RiskScore
import Common
@testable import Domain

@available(iOS 13.7, *)
class ExposureWindowInfectiousnessFactorCalculatorTests: XCTestCase {
    
    func testInfectiousnessFactor() {
        let expectedNoneInfectiousnessFactor = 0.0
        let expectedStandardInfectiousnessFactor = 0.5
        let expectedHighInfectiousnessFactor = 1.0
        var testConfig: ExposureDetectionConfiguration = .dummyForTesting
        testConfig.infectiousnessWeights = [expectedNoneInfectiousnessFactor, expectedStandardInfectiousnessFactor, expectedHighInfectiousnessFactor]
        
        let noneInfectiousness = ExposureWindowInfectiousnessFactorCalculator().infectiousnessFactor(for: .none, config: testConfig)
        let standardInfectiousness = ExposureWindowInfectiousnessFactorCalculator().infectiousnessFactor(for: .standard, config: testConfig)
        let highInfectiousness = ExposureWindowInfectiousnessFactorCalculator().infectiousnessFactor(for: .high, config: testConfig)
        
        XCTAssertEqual(expectedNoneInfectiousnessFactor, noneInfectiousness)
        XCTAssertEqual(expectedStandardInfectiousnessFactor, standardInfectiousness)
        XCTAssertEqual(expectedHighInfectiousnessFactor, highInfectiousness)
    }
}
