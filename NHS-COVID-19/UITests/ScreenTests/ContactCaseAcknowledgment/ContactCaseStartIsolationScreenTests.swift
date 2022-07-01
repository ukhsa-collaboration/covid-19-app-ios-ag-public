//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class ContactCaseStartIsolationScreenEnglandTests: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<ContactCaseStartIsolationScreenEnglandScenario>

    private let exposureDate = Date(timeIntervalSinceNow: -86400)

    private func screen(for app: XCUIApplication) -> ContactCaseStartIsolationScreenEngland {
        ContactCaseStartIsolationScreenEngland(
            app: app,
            isolationPeriod: 10,
            daysSinceEncounter: 1,
            remainingDays: 10
        )
    }

    func testBasics() throws {
        try runner.run { app in
            let screen = screen(for: app)
            XCTAssertTrue(screen.daysRemanining(with: runner.scenario.numberOfDays).exists)
            XCTAssertTrue(screen.infoBox.exists)
            XCTAssertTrue(screen.isolationListItem.exists)
            XCTAssertTrue(screen.lfdListItem.exists)
            XCTAssertTrue(screen.advice.exists)
        }
    }

    func testGuidanceLinkButton() throws {
        try runner.run { app in
            let screen = screen(for: app)
            app.scrollTo(element: screen.guidanceLink)
            screen.guidanceLink.tap()

            XCTAssertTrue(app.staticTexts[runner.scenario.guidanceLinkTapped].exists)
        }
    }

    func testBookAFreeTestButton() throws {
        try runner.run { app in
            let screen = screen(for: app)
            app.scrollTo(element: screen.bookAFreeTestButton)
            screen.bookAFreeTestButton.tap()

            XCTAssertTrue(app.staticTexts[runner.scenario.bookAFreeTestTapped].exists)
        }
    }

    func testBackToHomeButton() throws {
        try runner.run { app in
            let screen = screen(for: app)
            app.scrollTo(element: screen.backToHomeButton)
            screen.backToHomeButton.tap()

            XCTAssertTrue(app.staticTexts[runner.scenario.backToHomeTapped].exists)
        }
    }

}

class ContactCaseStartIsolationScreenWalesTests: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<ContactCaseStartIsolationScreenWalesScenario>

    private let exposureDate = Date(timeIntervalSinceNow: -86400)
    private let secondTestAdviceDate = Date(timeIntervalSinceNow: 86400 * 8)

    private func screen(for app: XCUIApplication) -> ContactCaseStartIsolationScreenWales {
        ContactCaseStartIsolationScreenWales(
            app: app,
            isolationPeriod: 10,
            daysSinceEncounter: 1,
            remainingDays: 10,
            secondTestAdviceDate: secondTestAdviceDate
        )
    }

    func testBasics() throws {
        try runner.run { app in
            let screen = screen(for: app)
            XCTAssertTrue(screen.daysRemaining(with: runner.scenario.numberOfDays).exists)
            XCTAssertTrue(screen.infoBox.exists)
            XCTAssertTrue(screen.isolationListItem.exists)
            XCTAssertTrue(screen.secondTestListItem.exists)
            XCTAssertTrue(screen.advice.exists)
        }
    }

    func testGuidanceLinkButton() throws {
        try runner.run { app in
            let screen = screen(for: app)
            app.scrollTo(element: screen.guidanceLink)
            screen.guidanceLink.tap()

            XCTAssertTrue(app.staticTexts[runner.scenario.guidanceLinkTapped].exists)
        }
    }

    func testBookAFreeTestButton() throws {
        try runner.run { app in
            let screen = screen(for: app)
            app.scrollTo(element: screen.getTestedButton)
            screen.getTestedButton.tap()

            XCTAssertTrue(app.staticTexts[runner.scenario.bookAFreeTestTapped].exists)
        }
    }

    func testBackToHomeButton() throws {
        try runner.run { app in
            let screen = screen(for: app)
            app.scrollTo(element: screen.backToHomeButton)
            screen.backToHomeButton.tap()

            XCTAssertTrue(app.staticTexts[runner.scenario.backToHomeTapped].exists)
        }
    }

}
