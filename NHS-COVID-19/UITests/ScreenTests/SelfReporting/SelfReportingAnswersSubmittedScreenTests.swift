//
// Copyright © 2022 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class AnswersSubmittedSharedKeysReportedResultScreenTest: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<AnswersSubmittedSharedKeysReportedResultScreenScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = AnswersSubmittedSharedKeysReportedResultScreen(app: app)
            XCTAssertTrue(screen.header.exists)
            XCTAssertTrue(screen.description.exists)
            XCTAssertTrue(screen.continueButton.exists)
        }
    }

    func testPrimaryButtons() throws {
        try runner.run { app in
            let screen = AnswersSubmittedSharedKeysReportedResultScreen(app: app)

            screen.app.scrollTo(element: screen.continueButton)
            XCTAssertTrue(screen.continueButton.isHittable)
            screen.continueButton.tap()
            XCTAssert(app.staticTexts[runner.scenario.primaryButtonTapped].exists)
        }
    }
}

class AnswersSubmittedSharedKeysNotReportedResultScreenTest: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<AnswersSubmittedSharedKeysNotReportedResultScreenScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = AnswersSubmittedSharedKeysNotReportedResultScreen(app: app)
            XCTAssertTrue(screen.header.exists)
            XCTAssertTrue(screen.description.exists)
            XCTAssertTrue(screen.infoBoxLabel.exists)
            XCTAssertTrue(screen.continueButton.exists)
        }
    }

    func testPrimaryButtons() throws {
        try runner.run { app in
            let screen = AnswersSubmittedSharedKeysNotReportedResultScreen(app: app)

            screen.app.scrollTo(element: screen.continueButton)
            XCTAssertTrue(screen.continueButton.isHittable)
            screen.continueButton.tap()
            XCTAssert(app.staticTexts[runner.scenario.primaryButtonTapped].exists)
        }
    }
}

class AnswersSubmittedNotSharedKeysReportedResultScreenTest: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<AnswersSubmittedNotSharedKeysReportedResultScreenScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = AnswersSubmittedNotSharedKeysReportedResultScreen(app: app)
            XCTAssertTrue(screen.header.exists)
            XCTAssertTrue(screen.description.exists)
            XCTAssertTrue(screen.continueButton.exists)
        }
    }

    func testPrimaryButtons() throws {
        try runner.run { app in
            let screen = AnswersSubmittedNotSharedKeysReportedResultScreen(app: app)

            screen.app.scrollTo(element: screen.continueButton)
            XCTAssertTrue(screen.continueButton.isHittable)
            screen.continueButton.tap()
            XCTAssert(app.staticTexts[runner.scenario.primaryButtonTapped].exists)
        }
    }
}

class AnswersSubmittedNotSharedKeysNotReportedResultScreenTest: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<AnswersSubmittedNotSharedKeysNotReportedResultScreenScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = AnswersSubmittedNotSharedKeysNotReportedResultScreen(app: app)
            XCTAssertTrue(screen.header.exists)
            XCTAssertTrue(screen.description.exists)
            XCTAssertTrue(screen.infoBoxLabel.exists)
            XCTAssertTrue(screen.continueButton.exists)
        }
    }

    func testPrimaryButtons() throws {
        try runner.run { app in
            let screen = AnswersSubmittedNotSharedKeysNotReportedResultScreen(app: app)

            screen.app.scrollTo(element: screen.continueButton)
            XCTAssertTrue(screen.continueButton.isHittable)
            screen.continueButton.tap()
            XCTAssert(app.staticTexts[runner.scenario.primaryButtonTapped].exists)
        }
    }
}
