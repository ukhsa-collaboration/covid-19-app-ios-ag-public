//
// Copyright © 2022 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class AdviceForIndexCasesEnglandScreenTests: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<AdviceForIndexCasesEnglandScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = AdviceForIndexCasesEnglandScreen(app: app)
            XCTAssertTrue(screen.heading.exists)
            XCTAssertTrue(screen.infoBox.exists)
            XCTAssertTrue(screen.body.exists)
            XCTAssertTrue(screen.commmonQuestionsLink.exists)
            XCTAssertTrue(screen.furtherAdvice.exists)
            XCTAssertTrue(screen.nhsOnlineLink.exists)
            XCTAssertTrue(screen.continueButton.exists)

        }
    }

    func testCommonQuestionsLinke() throws {
        try runner.run { app in
            let screen = AdviceForIndexCasesEnglandScreen(app: app)
            screen.commmonQuestionsLink.tap()
            XCTAssertTrue(app.staticTexts[AdviceForIndexCasesEnglandScenario.didTapCommonQuestionsLink].exists)
        }
    }

    func testNHSOnline() throws {
        try runner.run { app in
            let screen = AdviceForIndexCasesEnglandScreen(app: app)
            screen.nhsOnlineLink.tap()
            XCTAssertTrue(app.staticTexts[AdviceForIndexCasesEnglandScenario.ditTapNHSOnline].exists)
        }
    }

    func testContinueButton() throws {
        try runner.run { app in
            let screen = AdviceForIndexCasesEnglandScreen(app: app)
            screen.continueButton.tap()
            XCTAssertTrue(app.staticTexts[AdviceForIndexCasesEnglandScenario.didTapContinueButton].exists)
        }
    }
}
