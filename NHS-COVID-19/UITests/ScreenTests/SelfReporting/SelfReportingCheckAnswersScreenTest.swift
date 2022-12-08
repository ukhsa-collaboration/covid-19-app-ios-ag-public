//
// Copyright © 2022 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class SelfReportingCheckAnswersScreenTest: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<SelfReportingCheckAnswersScreenScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = SelfReportingCheckAnswersScreen(app: app)
            XCTAssertTrue(screen.header.exists)

            XCTAssertTrue(screen.testKitTypeQuestion.exists)
            XCTAssertTrue(screen.testKitTypeAnswerOption1.exists)
            XCTAssertFalse(screen.testKitTypeAnswerOption2.exists)
            XCTAssertTrue(screen.testKitTypeChangeButton.exists)

            XCTAssertTrue(screen.testSupplierQuestion.exists)
            XCTAssertTrue(screen.testSupplierAnswerOption1.exists)
            XCTAssertFalse(screen.testSupplierAnswerOption2.exists)
            XCTAssertTrue(screen.testSupplierChangeButton.exists)

            XCTAssertTrue(screen.testDayQuestion.exists)
            XCTAssertTrue(screen.testDayNoDateLabel.exists)
            XCTAssertTrue(screen.testDayChangeButton.exists)

            XCTAssertTrue(screen.symptomsQuestion.exists)
            XCTAssertTrue(screen.symptomsBulletedList.allExist)
            XCTAssertTrue(screen.symptomsAnswerOption1.exists)
            XCTAssertFalse(screen.symptomsAnswerOption2.exists)
            XCTAssertTrue(screen.symptomsChangeButton.exists)

            XCTAssertTrue(screen.symptomsDayQuestion.exists)
            XCTAssertTrue(screen.symptomsDayNoDateLabel.exists)
            XCTAssertTrue(screen.symptomsDayChangeButton.exists)

            XCTAssertTrue(screen.reportedResultQuestion.exists)
            XCTAssertTrue(screen.reportedResultAnswerOption1.exists)
            XCTAssertFalse(screen.reportedResultAnswerOption2.exists)
            XCTAssertTrue(screen.reportedResultChangeButton.exists)

            XCTAssertTrue(screen.continueButton.exists)
        }
    }

    func testChangeButtons() throws {
        try runner.run { app in
            let screen = SelfReportingCheckAnswersScreen(app: app)

            screen.app.scrollTo(element: screen.testKitTypeChangeButton)
            screen.testKitTypeChangeButton.tap()
            XCTAssert(app.staticTexts[runner.scenario.didTapChangeTestKitType].exists)

            screen.app.scrollTo(element: screen.testSupplierChangeButton)
            screen.testSupplierChangeButton.tap()
            XCTAssert(app.staticTexts[runner.scenario.didTapChangeTestSupplier].exists)

            screen.app.scrollTo(element: screen.testDayChangeButton)
            screen.testDayChangeButton.tap()
            XCTAssert(app.staticTexts[runner.scenario.didTapChangeTestDay].exists)

            screen.app.scrollTo(element: screen.symptomsChangeButton)
            screen.symptomsChangeButton.tap()
            XCTAssert(app.staticTexts[runner.scenario.didTapChangeSymptoms].exists)

            screen.app.scrollTo(element: screen.symptomsDayChangeButton)
            screen.symptomsDayChangeButton.tap()
            XCTAssert(app.staticTexts[runner.scenario.didTapChangeSymptomsDay].exists)

            screen.app.scrollTo(element: screen.reportedResultChangeButton)
            screen.reportedResultChangeButton.tap()
            XCTAssert(app.staticTexts[runner.scenario.didTapChangeReportedResult].exists)
        }
    }

    func testPrimaryButtons() throws {
        try runner.run { app in
            let screen = SelfReportingCheckAnswersScreen(app: app)

            screen.app.scrollTo(element: screen.continueButton)
            XCTAssertTrue(screen.continueButton.isHittable)
            screen.continueButton.tap()
            XCTAssert(app.staticTexts[runner.scenario.primaryButtonTapped].exists)
        }
    }
}
