//
// Copyright © 2022 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class AdviceReportedResultScreenTests: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<AdviceReportedResultScreenScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = AdviceReportedResultsScreen(app: app)
            XCTAssert(screen.headerLabel.exists)
            XCTAssertFalse(screen.infoSectionLink.exists)
            XCTAssertFalse(screen.infoSectionDescription.exists)
            XCTAssertFalse(screen.infoBox.exists)
            XCTAssert(screen.bulletedListHeader.exists)
            XCTAssert(screen.iconBullet1Label.exists)
            XCTAssert(screen.iconBullet2Label.exists)
            XCTAssert(screen.iconBullet3Label.exists)
            XCTAssert(screen.readMoreLink.exists)
            XCTAssert(screen.primaryButton.exists)
            XCTAssertFalse(screen.primaryLinkButton.exists)
        }
    }

    func testTapReadMoreLink() throws {
        try runner.run { app in
            let screen = AdviceReportedResultsScreen(app: app)
            screen.readMoreLink.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.readMoreLinkTapped].exists)
        }
    }

    func testTapPrimaryButton() throws {
        try runner.run { app in
            let screen = AdviceReportedResultsScreen(app: app)
            screen.primaryButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.backToHomeButtonTapped].exists)
        }
    }
}

