//
// Copyright © 2022 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class AdviceReportedResultOutOfIsolationScreenTests: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<AdviceReportedResultOutOfIsolationScreenScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = AdviceReportedResultsOutOfIsolationScreen(app: app)
            XCTAssert(screen.headerLabel.exists)
            XCTAssertFalse(screen.infoSectionLink.exists)
            XCTAssertFalse(screen.infoSectionDescription.exists)
            XCTAssert(screen.infoBox.exists)
            XCTAssertFalse(screen.bulletedListHeader.exists)
            XCTAssertFalse(screen.iconBullet1Label.exists)
            XCTAssertFalse(screen.iconBullet2Label.exists)
            XCTAssertFalse(screen.iconBullet3Label.exists)
            XCTAssert(screen.readMoreLink.exists)
            XCTAssert(screen.primaryButton.exists)
            XCTAssertFalse(screen.primaryLinkButton.exists)
        }
    }

    func testTapReadMoreLink() throws {
        try runner.run { app in
            let screen = AdviceReportedResultsOutOfIsolationScreen(app: app)
            screen.readMoreLink.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.readMoreLinkTapped].exists)
        }
    }

    func testTapPrimaryButton() throws {
        try runner.run { app in
            let screen = AdviceReportedResultsOutOfIsolationScreen(app: app)
            screen.primaryButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.backToHomeButtonTapped].exists)
        }
    }
}
