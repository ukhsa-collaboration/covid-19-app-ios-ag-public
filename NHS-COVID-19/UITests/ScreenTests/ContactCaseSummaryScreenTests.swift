//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class ContactCaseSummaryScreenTests: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<ContactCaseSummaryScreenScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = ContactCaseSummaryScreen(app: app)
            XCTAssertTrue(screen.title.exists)
            XCTAssertTrue(screen.heading.exists)

            // MARK: Age Q and A

            XCTAssertTrue(screen.ageHeader.exists)

            XCTAssertTrue(screen.ageQuestion(date: ContactCaseSummaryScreenScenario.birthThresholdDate).exists)

            XCTAssertTrue(screen.ageAnswer(date: ContactCaseSummaryScreenScenario.birthThresholdDate).exists)

            XCTAssertTrue(screen.changeAgeButton.exists)

            // MARK: Vaccine Q and A

            XCTAssertTrue(screen.vaccinationStatusHeader.exists)

            XCTAssertTrue(screen.fullyVaccinatedQuestion.exists)
            XCTAssertTrue(screen.fullyVaccinatedAnswer.exists)

            XCTAssertTrue(screen.lastDoseQuestion(date: ContactCaseSummaryScreenScenario.vaccineThresholdDate).exists)

            XCTAssertTrue(screen.lastDoseAnswer(date: ContactCaseSummaryScreenScenario.vaccineThresholdDate).exists)

            XCTAssertTrue(screen.changeVaccinationStatusButton.exists)

        }
    }

    func testChangeAgeButton() throws {
        try runner.run { app in
            let screen = ContactCaseSummaryScreen(app: app)
            screen.changeAgeButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.changeAgeAnswerButtonTapped].exists)
        }

    }

    func testChangeVaccinationStatusButton() throws {
        try runner.run { app in
            let screen = ContactCaseSummaryScreen(app: app)
            screen.changeVaccinationStatusButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.changeVaccinationStatusAnswerButtonTapped].exists)
        }

    }

    func testSubmitBUtton() throws {
        try runner.run { app in
            let screen = ContactCaseSummaryScreen(app: app)
            screen.submitButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.primaryButtonTappd].exists)
        }

    }

}
