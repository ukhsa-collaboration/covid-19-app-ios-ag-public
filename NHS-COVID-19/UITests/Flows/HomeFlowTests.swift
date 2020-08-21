//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import Scenarios
import XCTest

class HomeFlowTests: XCTestCase {
    @Propped
    private var runner: ApplicationRunner<SandboxedScenario>
    
    override func setUp() {
        $runner.initialState.isPilotActivated = true
        $runner.initialState.exposureNotificationsAuthorized = true
        $runner.initialState.userNotificationsAuthorized = true
        $runner.initialState.postcode = "SW12"
        $runner.initialState.riskLevel = "L"
    }
    
    func testHappyPath() throws {
        $runner.report(scenario: "HomeFlow", "Happy path") {
            """
            Users see the home screen and navigates to the different subpages
            """
        }
        try runner.run { app in
            let homeScreen = HomeScreen(app: app)
            
            XCTAssert(homeScreen.riskLevelBanner.exists)
            
            runner.step("More Info") {
                """
                Users can go to Risk level more info screen
                """
            }
            homeScreen.riskLevelBanner.tap()
            app.buttons[localize(.risk_level_screen_close_button)].tap()
            
            runner.step("Diagnosis") {
                """
                Users can navigate to self diagnosis page
                """
            }
            homeScreen.diagnoisButton.tap()
            
            app.buttons[localize(.cancel)].tap()
            
            runner.step("Check-In") {
                """
                Users can navigate to checkin page
                """
            }
            
            homeScreen.checkInButton.tap()
            
            app.buttons[localize(.checkin_qrcode_scanner_close_button_title)].tap()
            
            runner.step("About") {
                """
                Users can navigate to about page
                """
            }
            homeScreen.aboutButton.tap()
            
            app.buttons[localize(.back)].tap()
            
            runner.step("Disable Contact tracing") {
                """
                Users can disable contact tracing
                """
            }
            homeScreen.exposureNotificationSwitch.tap()
            
            XCTAssert(homeScreen.disabledContactTracing.exists)
            
        }
    }
}
