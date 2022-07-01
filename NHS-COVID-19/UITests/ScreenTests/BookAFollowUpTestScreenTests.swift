//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class BookAFollowUpTestScreenTests: XCTestCase {

    private typealias AlertTitle = BookAFollowUpTestScreenScenario.AlertTitle

    @Propped
    private var runner: ApplicationRunner<BookAFollowUpTestScreenScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = BookAFollowUpTestScreen(app: app)

            XCTAssertTrue(screen.heading.exists)
            XCTAssertTrue(screen.infoText.exists)

            screen.bodyTextElements.forEach {
                XCTAssertTrue($0.exists)
            }

            XCTAssertTrue(screen.adviceLinkLabel.exists)
            XCTAssertTrue(screen.adviceLinkButton.exists)
            XCTAssertTrue(screen.primaryButton.exists)
            XCTAssertTrue(screen.closeButton.exists)
        }
    }

    func testTapOnAdviceLinkButton() throws {
        try runner.run { app in
            let screen = BookAFollowUpTestScreen(app: app)

            XCTAssert(screen.adviceLinkButton.exists)
            screen.adviceLinkButton.tap()
            let adviceLinkAlertTitle = app.staticTexts[AlertTitle.nhsGuidanceLink]
            XCTAssert(adviceLinkAlertTitle.displayed)
        }
    }

    func testTapOnBookAFollowUpTestButton() throws {
        try runner.run { app in
            let screen = BookAFollowUpTestScreen(app: app)

            XCTAssert(screen.primaryButton.exists)
            XCTAssert(screen.primaryButton.isHittable)
            screen.primaryButton.tap()

            let bookAFollowUpTestAlertTitle = app.staticTexts[AlertTitle.primaryButton]
            XCTAssert(bookAFollowUpTestAlertTitle.displayed)
        }
    }

    func testTapOnCloseButton() throws {
        try runner.run { app in
            let screen = BookAFollowUpTestScreen(app: app)

            XCTAssert(screen.closeButton.exists)
            XCTAssert(screen.closeButton.isHittable)
            screen.closeButton.tap()
            let closeButtonAlertTitle = app.staticTexts[AlertTitle.closeButton]
            XCTAssert(closeButtonAlertTitle.displayed)
        }
    }

}
