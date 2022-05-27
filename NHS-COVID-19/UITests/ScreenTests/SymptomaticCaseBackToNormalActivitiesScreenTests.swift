//
// Copyright © 2022DHSC. All rights reserved.
//

import Scenarios
import XCTest

class SymptomaticCaseBackToNormalActivitiesScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<SymptomaticCaseSummaryContinueWithNormalActivitiesScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = SymptomaticCaseBackToNormalActivitiesScreen(app: app)
            XCTAssertTrue(screen.heading.exists)
            XCTAssertTrue(screen.yourAdiceInfoBox.exists)
            XCTAssertTrue(screen.yourAdiceInforText1.exists)
            XCTAssertTrue(screen.yourAdviceLink.exists)
            XCTAssertTrue(screen.yourAdiceInforText2.exists)
            XCTAssertTrue(screen.whenToseekMedicalAdviceHeader.exists)
            XCTAssertTrue(screen.nhsInfoSubHeader.exists)
            XCTAssertTrue(screen.worriedAboutYourSymptomsBullets().exists)
            XCTAssertTrue(screen.onlineServicesLink.exists)
            XCTAssertTrue(screen.infoEmergencyText.exists)
            XCTAssertTrue(screen.backToHomeButton.exists)
        }
    }
    
    func testSymptomCheckerNormalActivitiesLink() throws {
        try runner.run { app in
            let screen = SymptomaticCaseBackToNormalActivitiesScreen(app: app)
            
            screen.yourAdviceLink.tap()
            XCTAssertTrue(screen.testSymptomCheckerNormalActivitiesLink.exists)
        }
    }
    
    func testOnlineServicesLink() throws {
        try runner.run { app in
            let screen = SymptomaticCaseBackToNormalActivitiesScreen(app: app)
            
            screen.onlineServicesLink.tap()
            XCTAssertTrue(screen.testOnlineServiceLink.exists)
        }
    }
    
    func testBackToHomeButton() throws {
        try runner.run { app in
            let screen = SymptomaticCaseBackToNormalActivitiesScreen(app: app)
            
            screen.backToHomeButton.tap()
            XCTAssertTrue(screen.testBackToHomeButton.exists)
        }
    }
}
