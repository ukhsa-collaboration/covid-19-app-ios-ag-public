//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class PermissionsScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<PermissionsScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = PermissionsScreen(app: app)
            
            XCTAssert(screen.stepTitle.exists)
            XCTAssert(screen.exposureNotificationHeading.exists)
            XCTAssert(screen.notificationsHeading.exists)
            XCTAssert(screen.exposureNotificationBody.exists)
            XCTAssert(screen.notificationsBody.exists)
            XCTAssert(screen.continueButton.exists)
        }
    }
    
    func testContinueButton() throws {
        $runner.report("Happy path") {
            """
            Present permission request information
            """
        }
        try runner.run { app in
            let screen = PermissionsScreen(app: app)
            
            XCTAssert(screen.stepTitle.exists)
            
            runner.step("Start") {
                """
                The user is informed about permissions need by the app.
                """
            }
            
            screen.continueButton.tap()
            
            runner.step("Continued") {
                """
                The user has tapped continued. In a live version of the app they would see the permission alert dialogs.
                """
            }
            
            XCTAssertTrue(app.staticTexts[runner.scenario.continueConfirmationAlertTitle].exists)
        }
    }
}
