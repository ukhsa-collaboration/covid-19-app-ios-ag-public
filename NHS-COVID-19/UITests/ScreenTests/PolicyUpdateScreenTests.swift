//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class PolicyUpdateScreenTests: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<PolicyUpdateScreenScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = PolicyUpdateScreen(app: app)
            XCTAssertTrue(screen.title.exists)
            XCTAssertTrue(screen.description.allExist)
            XCTAssertTrue(screen.link.exists)
            XCTAssertTrue(screen.button.exists)
        }
    }

    func testTermsOfUse() throws {
        try runner.run { app in
            let screen = PolicyUpdateScreen(app: app)
            screen.link.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.termsOfUseTapped].exists)
        }
    }

    func testContinue() throws {
        try runner.run { app in
            let screen = PolicyUpdateScreen(app: app)
            screen.button.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.continueTapped].exists)
        }
    }
}
