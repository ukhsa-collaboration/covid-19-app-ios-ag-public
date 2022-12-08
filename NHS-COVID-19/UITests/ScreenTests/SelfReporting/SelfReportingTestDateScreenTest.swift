//
// Copyright © 2022 DHSC. All rights reserved.
//

import Common
import Scenarios
import XCTest

class SelfReportingTestDateScreenTest: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<SelfReportingTestDateScreenScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = SelfReportingTestDateScreen(app: app)
            XCTAssertTrue(screen.header.exists)
            XCTAssertTrue(screen.doNotRememberNotChecked.exists)
            XCTAssertTrue(screen.dateTextField.exists)
            XCTAssertTrue(screen.dateButton.exists)
            XCTAssertTrue(screen.continueButton.exists)

            XCTAssertFalse(screen.errorBox.exists)
            XCTAssertFalse(screen.errorDescription.exists)
            XCTAssertFalse(screen.doNotRememberChecked.exists)
        }
    }

    func testErrorAppearance() throws {
        try runner.run { app in
            let screen = SelfReportingTestDateScreen(app: app)
            XCTAssertTrue(screen.continueButton.isHittable)
            screen.continueButton.tap()
            XCTAssertTrue(screen.errorBox.exists)
        }
    }

    func testErrorDisappearance() throws {
        try runner.run { app in
            let screen = SelfReportingTestDateScreen(app: app)
            screen.continueButton.tap()
            XCTAssertTrue(screen.errorBox.exists)

            screen.doNotRememberNotChecked.tap()
            screen.continueButton.tap()
            XCTAssertFalse(screen.errorBox.exists)
        }
    }

    func testDoNotRemember() throws {
        try runner.run { app in
            let screen = SelfReportingTestDateScreen(app: app)
            screen.doNotRememberNotChecked.tap()
            screen.continueButton.tap()
            XCTAssertTrue(screen.doNotRememberChecked.exists)
            XCTAssertTrue(app.staticTexts[runner.scenario.doNotRememberChecked].exists)
        }
    }

    func testChangingDateChangesTextInField() throws {
        try runner.run { app in
            let screen = SelfReportingTestDateScreen(app: app)
            let field = screen.dateButton

            XCTAssertTrue(field.exists)
            XCTAssertEqual(field.label, localize(.self_report_test_date_placeholder))

            screen.dateTextField.tap()

            let threeDaysAgo = localize(.symptom_onset_select_day(
                GregorianDay.today
                    .advanced(by: -3)
                    .startDate(in: .current))
            )
            app.pickerWheels.element.adjust(toPickerWheelValue: threeDaysAgo)
            app.buttons[localized: .done].tap()

            XCTAssertEqual(field.stringValue, threeDaysAgo)

            screen.doNotRememberNotChecked.tap()
            XCTAssertEqual(field.label, localize(.self_report_test_date_placeholder))
        }
    }
}
