//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class ContactCaseExposureInfoScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<ContactCaseExposureInfoScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = ContactCaseExposureInfoScreen(app: app)
            XCTAssert(screen.headingText.exists)
            XCTAssert(screen.infoBoxText.exists)
            XCTAssert(screen.ifYouHaveSymptomsText.exists)
            XCTAssert(screen.continueButton.exists)
        }
    }
    
    func testTappingContinue() throws {
        try runner.run { app in
            let screen = ContactCaseExposureInfoScreen(app: app)
            screen.continueButton.tap()
            XCTAssert(screen.alertOnTappingContinueButton.exists)
        }
    }
}
