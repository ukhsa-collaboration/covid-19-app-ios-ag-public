//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Scenarios
import XCTest

class TestSymptomsReviewScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<TestSymptomsReviewScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = TestSymptomsReviewScreen(app: app)
            XCTAssertTrue(screen.headingLabel.exists)
            XCTAssertTrue(screen.descriptionLabel.allExist)
            XCTAssertTrue(screen.continueButton.exists)
            XCTAssertTrue(screen.noDate.exists)
        }
    }
    
    func testConfirmSymptoms() throws {
        try runner.run { app in
            let screen = TestSymptomsReviewScreen(app: app)
            screen.noDate.tap()
            screen.continueButton.tap()
            XCTAssertTrue(screen.confirmAlertText.exists)
        }
    }
    
    func testChangingDateChangesTextInField() throws {
        try runner.run { app in
            let screen = TestSymptomsReviewScreen(app: app)
            let field = screen.dateButton
            
            XCTAssertTrue(field.exists)
            XCTAssertEqual(field.label, localize(.symptom_review_date_placeholder))
            
            screen.dateTextField.tap()
            
            let threeDaysAgo = localize(.symptom_onset_select_day(
                GregorianDay.today
                    .advanced(by: -3)
                    .startDate(in: .current)))
            app.pickerWheels.element.adjust(toPickerWheelValue: threeDaysAgo)
            app.buttons[localized: .done].tap()
            
            XCTAssertEqual(field.stringValue, threeDaysAgo)
            
            screen.noDate.tap()
            XCTAssertEqual(field.label, localize(.symptom_review_date_placeholder))
        }
    }
}
