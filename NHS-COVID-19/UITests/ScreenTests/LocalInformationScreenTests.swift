//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import Scenarios
import XCTest

final class LocalInformationScreenParagraphsOnlyScenarioTests: XCTestCase {

    private typealias AlertTitle = LocalInformationScreenAlertTitle
    private typealias Content = LocalInformationScreenParagraphsOnlyScenario.Content

    @Propped
    private var runner: ApplicationRunner<LocalInformationScreenParagraphsOnlyScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = ParagraphsOnlyLocalInformationScreen(app: app)

            XCTAssert(screen.cancelButton.exists)
            XCTAssert(screen.header.exists)
            XCTAssert(screen.paragraph1.exists)
            XCTAssert(screen.linkButton1.exists)
            XCTAssert(screen.paragraph2.exists)
            XCTAssert(screen.linkButton2.exists)
            XCTAssert(screen.primaryButton.exists)
        }
    }

    func testTapOnCancelButton() throws {
        try runner.run { app in
            let screen = ParagraphsOnlyLocalInformationScreen(app: app)

            XCTAssert(screen.cancelButton.exists)
            screen.cancelButton.tap()
            let cancelButtonAlertTitle = app.staticTexts[AlertTitle.cancelButton]
            XCTAssert(cancelButtonAlertTitle.displayed)
        }
    }

    func testTapOnLinkButton1() throws {
        try runner.run { app in
            let screen = ParagraphsOnlyLocalInformationScreen(app: app)

            XCTAssert(screen.linkButton1.exists)
            screen.linkButton1.tap()
            let linkButtonAlertTitle = app.staticTexts[AlertTitle.externalLink(url: Content.Body.link1.url)]
            XCTAssert(linkButtonAlertTitle.displayed)
        }
    }

    func testTapOnLinkButton2() throws {
        try runner.run { app in
            let screen = ParagraphsOnlyLocalInformationScreen(app: app)

            XCTAssert(screen.linkButton2.exists)
            screen.linkButton2.tap()
            let linkButtonAlertTitle = app.staticTexts[AlertTitle.externalLink(url: Content.Body.link2.url)]
            XCTAssert(linkButtonAlertTitle.displayed)
        }
    }

    func testTapOnPrimaryButton() throws {
        try runner.run { app in
            let screen = ParagraphsOnlyLocalInformationScreen(app: app)

            XCTAssert(screen.primaryButton.exists)
            screen.primaryButton.tap()
            let primaryButtonAlertTitle = app.staticTexts[AlertTitle.primaryButton]
            XCTAssert(primaryButtonAlertTitle.displayed)
        }
    }

}
