//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class MyDataScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<MyDataScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = MyDataScreen(app: app)
            XCTAssertTrue(screen.testResultSectionHeader.exists)
            XCTAssertTrue(screen.testResult(testResult: localize(.mydata_test_result_positive)).exists)
            XCTAssertTrue(screen.cellTestKitType(testKitType: localize(.mydata_test_result_lab_result)).exists)
            XCTAssertTrue(screen.cellDate(date: runner.scenario.testResultDate).exists)
            XCTAssertTrue(screen.cellDate(date: runner.scenario.encounterDate).exists)
            XCTAssertTrue(screen.cellDate(date: runner.scenario.symptomsDate).exists)
        }
    }
}
