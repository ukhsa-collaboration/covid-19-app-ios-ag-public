//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Scenarios
import XCTest

class ExposureNotificationFlowTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<SandboxedScenario>
    
    override func setUp() {
        $runner.initialState.isPilotActivated = true
        $runner.initialState.exposureNotificationsAuthorized = true
        $runner.initialState.userNotificationsAuthorized = false
        $runner.initialState.postcode = "S1"
        $runner.initialState.localAuthorityId = "E08000019" // Sheffield
    }
    
    func testReceiveExposureNotification() throws {
        $runner.report(scenario: "Exposure Notification", "Happy path") {
            """
            User receives an exposure notification,
            User acknowledges the notification and reaches Home screen again
            """
        }
        $runner.initialState.isolationCase = Sandbox.Text.IsolationCase.contact.rawValue
        $runner.initialState.hasAcknowledgedStartOfIsolation = false
        try runner.run { app in
            
            let contactCaseAcknowledgementScreen = ContactCaseAcknowledgementScreen(app: app)
            XCTAssertTrue(contactCaseAcknowledgementScreen.acknowledgementButton.exists)
            
            runner.step("Exposure Notification screen") {
                """
                The user is presented the Exposure Notification screen.
                The user presses the I Undestand Button to continue.
                """
            }
            
            contactCaseAcknowledgementScreen.acknowledgementButton.tap()
            
            runner.step("Home screen") {
                """
                The user is presented the Home screen and is Isolating.
                """
            }
            
            let date = GregorianDay.today.advanced(by: Sandbox.Config.Isolation.contactCaseSinceExposureDay).startDate(in: .current)
            app.checkOnHomeScreenIsolating(date: date, days: Sandbox.Config.Isolation.contactCaseSinceExposureDay)
        }
    }
}
