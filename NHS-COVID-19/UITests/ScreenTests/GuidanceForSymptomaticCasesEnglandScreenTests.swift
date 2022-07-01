//
// Copyright © 2022 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class GuidanceForSymptomaticCasesEnglandScreenTests: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<GuidanceForSymptomaticCasesEnglandViewControllerScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = GuidanceForSymptomaticCasesEnglandScreen(app: app)
            for element in screen.allElements {
                app.scrollTo(element: element)
                XCTAssertTrue(element.exists, "Could not found \(element)")
            }
        }
    }

    func testCommonQuestionsLink() throws {
        try runner.run { app in
            let screen = GuidanceForSymptomaticCasesEnglandScreen(app: app)
            app.scrollTo(element: screen.commonQuestionsLink)
            screen.commonQuestionsLink.tap()

            XCTAssertTrue(app.staticTexts[runner.scenario.commonQuestionsLinkTapped].exists)
        }
    }

    func testNHSOnlineLink() throws {
        try runner.run { app in
            let screen = GuidanceForSymptomaticCasesEnglandScreen(app: app)
            app.scrollTo(element: screen.nhsOnlineLink)
            screen.nhsOnlineLink.tap()

            XCTAssertTrue(app.staticTexts[runner.scenario.nhsOnlineLinkTapped].exists)
        }
    }

    func testBackToHomeButton() throws {
        try runner.run { app in
            let screen = GuidanceForSymptomaticCasesEnglandScreen(app: app)
            screen.backToHomeButton.tap()

            XCTAssertTrue(app.staticTexts[runner.scenario.backToHomeTapped].exists)
        }
    }
}

