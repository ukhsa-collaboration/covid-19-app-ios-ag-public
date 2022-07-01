//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class SymptomsListScreenTests: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<SymptomsListViewControllerScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = SymptomsListScreen(app: app)

            XCTAssert(screen.stepsLabel.exists)
            XCTAssert(screen.heading.exists)
            XCTAssert(screen.description.exists)
            XCTAssert(screen.symptomCard(
                value: SymptomsListViewControllerScenario.symptom1Value,
                heading: SymptomsListViewControllerScenario.symptom1Heading,
                content: SymptomsListViewControllerScenario.symptom1Content
            ).exists)
            XCTAssert(screen.symptomCard(
                value: SymptomsListViewControllerScenario.symptom2Value,
                heading: SymptomsListViewControllerScenario.symptom2Heading,
                content: SymptomsListViewControllerScenario.symptom2Content
            ).exists)
            XCTAssert(screen.reportButton.exists)
            XCTAssert(screen.noSymptomsButton.exists)
        }
    }

    func testReportSymptoms() throws {
        try runner.run { app in
            let screen = SymptomsListScreen(app: app)

            screen.reportButton.tap()
            XCTAssert(screen.reportAlertTitle.exists)
        }
    }

    func testAlertBasics() throws {
        try runner.run { app in
            let screen = SymptomsListScreen(app: app)
            app.scrollTo(element: screen.noSymptomsButton)
            screen.noSymptomsButton.tap()

            XCTAssert(screen.discardAlertBody.exists)
            XCTAssert(screen.discardAlertTitle.exists)
            XCTAssert(screen.discardAlertCancel.exists)
            XCTAssert(screen.discardAlertDiscard.exists)
        }
    }

    func testAlertDiscard() throws {
        try runner.run { app in
            let screen = SymptomsListScreen(app: app)
            app.scrollTo(element: screen.noSymptomsButton)

            screen.noSymptomsButton.tap()
            XCTAssert(screen.discardAlertDiscard.exists)
            screen.discardAlertDiscard.tap()
            XCTAssert(screen.noSymptomsAlertTitle.exists)
        }
    }

    func testAlertCancel() throws {
        try runner.run { app in
            let screen = SymptomsListScreen(app: app)
            app.scrollTo(element: screen.noSymptomsButton)

            screen.noSymptomsButton.tap()
            XCTAssert(screen.discardAlertCancel.exists)
            screen.discardAlertCancel.tap()
            XCTAssertFalse(screen.noSymptomsAlertTitle.exists)
        }
    }
}
