//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class LoadingFailedScreenTests: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<LoadingFailedScreenTemplateScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = LoadingFailedScreen(app: app)

            XCTAssert(screen.descriptionHeading.exists)
            XCTAssert(screen.descriptionLabel.exists)
            XCTAssert(screen.retryButton.exists)
        }
    }

    func testTapRetry() throws {
        try runner.run { app in
            let screen = LoadingFailedScreen(app: app)

            screen.retryButton.tap()
            XCTAssert(screen.retryButtonAlertTitle.exists)
        }
    }
}
