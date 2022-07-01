//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class UnknownTestResultsScreenTests: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<UnknownTestResultsScreenScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = UnknownTestResultsScreen(app: app)
            XCTAssert(screen.headingLabel.exists)
            XCTAssert(screen.descriptionLabel.allExist)
            XCTAssert(screen.openStoreButton.exists)
        }
    }

    func testPrimaryButtonTap() throws {
        try runner.run { app in
            let screen = UnknownTestResultsScreen(app: app)
            screen.openStoreButton.tap()
            XCTAssert(screen.openStoreButton.exists)
        }
    }
}

private extension UnknownTestResultsScreen {

    var openStoreAlertTitle: XCUIElement {
        app.staticTexts[UnknownTestResultsScreenScenario.openStoreTapped]
    }
}
