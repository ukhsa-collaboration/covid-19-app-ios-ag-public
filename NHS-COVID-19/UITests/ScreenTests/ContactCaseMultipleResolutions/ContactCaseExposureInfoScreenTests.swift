//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class ContactCaseExposureInfoScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<ContactCaseExposureInfoScenario>
    
    private let date = DateComponents(calendar: .gregorian, timeZone: .utc, year: 2021, month: 8, day: 1).date!
    
    func testBasics() throws {
        try runner.run { app in
            let screen = ContactCaseExposureInfoScreen(app: app, date: date)
            XCTAssert(screen.headingText.exists)
            XCTAssert(screen.infoBoxText.exists)
            XCTAssert(screen.accordionHeading.exists)
            XCTAssert(screen.ifYouHaveSymptomsText.exists)
            XCTAssert(screen.continueButton.exists)
        }
    }
    
    func testTappingContinue() throws {
        try runner.run { app in
            let screen = ContactCaseExposureInfoScreen(app: app, date: date)
            screen.continueButton.tap()
            XCTAssert(screen.alertOnTappingContinueButton.exists)
        }
    }
    
    func testOpeningAccordion() throws {
        try runner.run { app in
            let screen = ContactCaseExposureInfoScreen(app: app, date: date)
            screen.accordionHeading.tap()
            app.scrollTo(element: screen.accordionBodyElements[0])
            for element in screen.accordionBodyElements {
                XCTAssertTrue(element.exists)
            }
        }
    }
}
