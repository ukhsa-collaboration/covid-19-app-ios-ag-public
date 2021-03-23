//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Scenarios
import XCTest

class SymptomsReviewScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<SymptomsReviewViewControllerScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = SymptomsReviewScreen(app: app)
            
            XCTAssert(screen.stepsLabel.exists)
            XCTAssert(screen.heading.exists)
            XCTAssert(screen.confirmHeading.exists)
            XCTAssert(screen.denyHeading.exists)
            XCTAssert(screen.dateHeading.exists)
            XCTAssert(screen.noDate.exists)
            XCTAssert(screen.confirmButton.exists)
        }
    }
    
    func testConfirmSymptoms() throws {
        try runner.run { app in
            let screen = SymptomsReviewScreen(app: app)
            screen.noDate.tap()
            screen.confirmButton.tap()
            XCTAssert(screen.confirmAlertText.exists)
        }
    }
    
    func testChangeSymptoms() throws {
        try runner.run { app in
            let screen = SymptomsReviewScreen(app: app)
            screen.changeButton.tap()
            XCTAssert(screen.changeAlertText.exists)
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
