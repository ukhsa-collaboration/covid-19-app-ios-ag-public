//
// Copyright © 2020 NHSX. All rights reserved.
//

import XCTest
import ExposureNotification
@testable import Domain

@available(iOS 13.7, *)
class ExposureDetectionConfigurationTests: XCTestCase {
    private let daysSinceOnsetToInfectiousness = [
        0, 0, 0, 0, 0, 0, 0, 0, 0,
        1, 1, 1,
        2, 2, 2, 2, 2, 2,
        1, 1, 1, 1, 1, 1,
        0, 0, 0, 0, 0
    ]
    
    func testCovertsArrayOfInfectiousnessToMap() {
        var config = ExposureDetectionConfiguration.dummyForTesting
        config.daysSinceOnsetToInfectiousness = daysSinceOnsetToInfectiousness
        
        let mappedConfig = ENExposureConfiguration(from: config)
        
        XCTAssertEqual(mappedConfig.infectiousnessForDaysSinceOnsetOfSymptoms, expectedInfectiousnessMap)
    }
    
    private let expectedInfectiousnessMap = [
        NSNumber(value: -14): NSNumber(value: ENInfectiousness.none.rawValue),
        NSNumber(value: -13): NSNumber(value: ENInfectiousness.none.rawValue),
        NSNumber(value: -12): NSNumber(value: ENInfectiousness.none.rawValue),
        NSNumber(value: -11): NSNumber(value: ENInfectiousness.none.rawValue),
        NSNumber(value: -10): NSNumber(value: ENInfectiousness.none.rawValue),
        NSNumber(value: -9): NSNumber(value: ENInfectiousness.none.rawValue),
        NSNumber(value: -8): NSNumber(value: ENInfectiousness.none.rawValue),
        NSNumber(value: -7): NSNumber(value: ENInfectiousness.none.rawValue),
        NSNumber(value: -6): NSNumber(value: ENInfectiousness.none.rawValue),
        NSNumber(value: -5): NSNumber(value: ENInfectiousness.standard.rawValue),
        NSNumber(value: -4): NSNumber(value: ENInfectiousness.standard.rawValue),
        NSNumber(value: -3): NSNumber(value: ENInfectiousness.standard.rawValue),
        NSNumber(value: -2): NSNumber(value: ENInfectiousness.high.rawValue),
        NSNumber(value: -1): NSNumber(value: ENInfectiousness.high.rawValue),
        NSNumber(value: -0): NSNumber(value: ENInfectiousness.high.rawValue),
        NSNumber(value: 1): NSNumber(value: ENInfectiousness.high.rawValue),
        NSNumber(value: 2): NSNumber(value: ENInfectiousness.high.rawValue),
        NSNumber(value: 3): NSNumber(value: ENInfectiousness.high.rawValue),
        NSNumber(value: 4): NSNumber(value: ENInfectiousness.standard.rawValue),
        NSNumber(value: 5): NSNumber(value: ENInfectiousness.standard.rawValue),
        NSNumber(value: 6): NSNumber(value: ENInfectiousness.standard.rawValue),
        NSNumber(value: 7): NSNumber(value: ENInfectiousness.standard.rawValue),
        NSNumber(value: 8): NSNumber(value: ENInfectiousness.standard.rawValue),
        NSNumber(value: 9): NSNumber(value: ENInfectiousness.standard.rawValue),
        NSNumber(value: 10): NSNumber(value: ENInfectiousness.none.rawValue),
        NSNumber(value: 11): NSNumber(value: ENInfectiousness.none.rawValue),
        NSNumber(value: 12): NSNumber(value: ENInfectiousness.none.rawValue),
        NSNumber(value: 13): NSNumber(value: ENInfectiousness.none.rawValue),
        NSNumber(value: 14): NSNumber(value: ENInfectiousness.none.rawValue)
    ]
}
