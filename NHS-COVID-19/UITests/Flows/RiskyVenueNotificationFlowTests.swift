//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation
import XCTest

class RiskyVenueNotificationFlowTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<SandboxedScenario>
    
    override func setUpWithError() throws {
        $runner.initialState.isPilotActivated = true
        $runner.initialState.exposureNotificationsAuthorized = true
        $runner.initialState.userNotificationsAuthorized = false
        $runner.initialState.postcode = "S1"
        $runner.initialState.localAuthorityId = "Sheffield"
    }
    
    func testShowWarnAndInformRiskyVenueNotification() throws {
        $runner.initialState.riskyVenueMessageType = Sandbox.Text.RiskyVenueMessageType.warnAndInform.rawValue
        
        $runner.report(scenario: "Risky venue notification", "Warn and inform") {
            """
            User receives a warn and inform risky venue notification,
            User acknowledges the notification and goes back to home screen.
            """
        }
        
        try runner.run { app in
            
            let riskyVenueInformationScreen = RiskyVenueInformationScreen(app: app, venueName: "Venue 1", checkInDate: DateProvider().currentDate)
            XCTAssertTrue(riskyVenueInformationScreen.actionButton.exists)
            
            runner.step("Risky Venue Notification screen") {
                """
                The user is presented the warn and inform risky venue notification screen.
                The user taps on Back To Home button.
                """
            }
            
            riskyVenueInformationScreen.actionButton.tap()
            
            runner.step("Home screen") {
                """
                The user is presented the Home screen again.
                """
            }
        }
    }
    
    func testShowWarnAndBookATestRiskyVenueNotification() throws {
        $runner.initialState.riskyVenueMessageType = Sandbox.Text.RiskyVenueMessageType.warnAndBookATest.rawValue
        
        $runner.report(scenario: "Risky venue notification", "Warn and book a test") {
            """
            User receives a warn and book a test risky venue notification,
            User taps on book a test for yourself button,
            User goes through the book a test flow, and comes back to home screen.
            """
        }
        
        try runner.run { app in
            
            let riskyVenueInformationBookATestScreen = RiskyVenueInformationBookATestScreen(app: app)
            XCTAssertTrue(riskyVenueInformationBookATestScreen.bookATestButton.exists)
            
            runner.step("Risky Venue Notification screen") {
                """
                The user is presented the warn and book a test risky venue notification.
                The user taps on book a free test button.
                """
            }
            
            riskyVenueInformationBookATestScreen.bookATestButton.tap()
            
            let bookATestScreen = BookATestScreen(app: app)
            XCTAssertTrue(bookATestScreen.button.exists)
            
            runner.step("Book a Free Test screen") {
                """
                The user is presented the Book a free test screen.
                The user taps on book a test for yourself button
                The user gets redirected to a web browser to book a test
                """
            }
            
            bookATestScreen.button.tap()
            
            runner.step("Home screen") {
                """
                The user goes back to home screen
                """
            }
        }
    }
}
