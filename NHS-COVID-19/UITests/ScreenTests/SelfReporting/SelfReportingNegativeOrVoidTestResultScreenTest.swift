//
// Copyright © 2022 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class SelfReportingNegativeOrVoidTestResultScreenTest: XCTestCase {

    @Propped
    private var runnerEngland: ApplicationRunner<SelfReportingNegativeOrVoidTestResultEnglandScreenScenario>

    @Propped
    private var runnerWales: ApplicationRunner<SelfReportingNegativeOrVoidTestResultWalesScreenScenario>

    func testBasicsEngland() throws {
        try runnerEngland.run { app in
            let screen = SelfReportingNegativeOrVoidTestResultScreen(app: app)
            XCTAssertTrue(screen.header.exists)
            XCTAssertTrue(screen.body_one.exists)
            XCTAssertTrue(screen.findOutMoreLink.exists)
            XCTAssertTrue(screen.body_two.exists)
            XCTAssertTrue(screen.sectionTitle.exists)
            XCTAssertTrue(screen.body_three.exists)
            XCTAssertTrue(screen.body_four.exists)
            XCTAssertTrue(screen.nhs111OnlineLink.exists)
            XCTAssertTrue(screen.primaryButton.exists)
        }
    }

    func testBasicsWales() throws {
        try runnerWales.run { app in
            let screen = SelfReportingNegativeOrVoidTestResultScreen(app: app)
            XCTAssertTrue(screen.header.exists)
            XCTAssertTrue(screen.body_one.exists)
            XCTAssertFalse(screen.findOutMoreLink.exists)
            XCTAssertFalse(screen.body_two.exists)
            XCTAssertTrue(screen.sectionTitle.exists)
            XCTAssertTrue(screen.body_three.exists)
            XCTAssertTrue(screen.body_four.exists)
            XCTAssertTrue(screen.nhs111OnlineLink.exists)
            XCTAssertTrue(screen.primaryButton.exists)
        }
    }

    func testFindOutMoreLink() throws {
        try runnerEngland.run { app in
            let screen = SelfReportingNegativeOrVoidTestResultScreen(app: app)
            app.scrollTo(element: screen.findOutMoreLink)
            XCTAssertTrue(screen.findOutMoreLink.isHittable)
            screen.findOutMoreLink.tap()
            XCTAssert(app.staticTexts[runnerEngland.scenario.findOutMoreLink].exists)
        }
    }

    func testNHS111OnlineLink() throws {
        try runnerEngland.run { app in
            let screen = SelfReportingNegativeOrVoidTestResultScreen(app: app)
            app.scrollTo(element: screen.nhs111OnlineLink)
            XCTAssertTrue(screen.nhs111OnlineLink.isHittable)
            screen.nhs111OnlineLink.tap()
            XCTAssert(app.staticTexts[runnerEngland.scenario.nhs111OnlineLink].exists)
        }
    }

    func testPrimaryButton() throws {
        try runnerEngland.run { app in
            let screen = SelfReportingNegativeOrVoidTestResultScreen(app: app)
            app.scrollTo(element: screen.primaryButton)
            XCTAssertTrue(screen.primaryButton.isHittable)
            screen.primaryButton.tap()
            XCTAssert(app.staticTexts[runnerEngland.scenario.primaryButtonTapped].exists)
        }
    }
}
