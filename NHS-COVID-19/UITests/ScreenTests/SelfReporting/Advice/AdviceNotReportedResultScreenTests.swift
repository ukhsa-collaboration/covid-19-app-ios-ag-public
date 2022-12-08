//
// Copyright © 2022 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class AdviceNotReportedResultScreenTests: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<AdviceNotReportedResultScreenScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = AdviceNotReportedResultsScreen(app: app)
            XCTAssert(screen.headerLabel.exists)
            XCTAssert(screen.infoSectionLink.exists)
            XCTAssert(screen.infoSectionDescription.exists)
            XCTAssert(screen.subHeaderLabel.exists)
            XCTAssertFalse(screen.infoBox.exists)
            XCTAssert(screen.bulletedListHeader.exists)
            XCTAssert(screen.iconBullet1Label.exists)
            XCTAssert(screen.iconBullet2Label.exists)
            XCTAssert(screen.iconBullet3Label.exists)
            XCTAssert(screen.readMoreLink.exists)
            XCTAssert(screen.primaryLinkButton.exists)
            XCTAssert(screen.secondaryLinkButton.exists)
        }
    }

    func testTapReportResultInfoSectionLink() throws {
        try runner.run { app in
            let screen = AdviceNotReportedResultsScreen(app: app)
            screen.infoSectionLink.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.reportResultLinkTapped].exists)
        }
    }

    func testTapReadMoreLink() throws {
        try runner.run { app in
            let screen = AdviceNotReportedResultsScreen(app: app)
            screen.readMoreLink.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.readMoreLinkTapped].exists)
        }
    }

    func testTapPrimaryLinkButton() throws {
        try runner.run { app in
            let screen = AdviceNotReportedResultsScreen(app: app)
            screen.primaryLinkButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.reportResultLinkTapped].exists)
        }
    }

    func testTapSecondaryLinkButton() throws {
        try runner.run { app in
            let screen = AdviceNotReportedResultsScreen(app: app)
            screen.secondaryLinkButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.backToHomeButtonTapped].exists)
        }
    }
}
