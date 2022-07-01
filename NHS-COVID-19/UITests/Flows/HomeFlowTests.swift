//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import Scenarios
import XCTest

class HomeFlowTests: XCTestCase {
    private let postcode = "SW12"

    @Propped
    private var runner: ApplicationRunner<SandboxedScenario>

    override func setUp() {
        $runner.initialState.exposureNotificationsAuthorized = true
        $runner.initialState.userNotificationsAuthorized = false
        $runner.initialState.cameraAuthorized = true
        $runner.initialState.postcode = postcode
        $runner.initialState.localAuthorityId = "E09000022"
    }

    func testContactTracingReenableSwitch() throws {

        $runner.initialState.exposureNotificationsEnabled = false

        try runner.run { app in
            let homeScreen = HomeScreen(app: app)

            app.checkOnHomeScreen(postcode: postcode)

            runner.step("Enable Contact tracing") {
                """
                Users can enable contact tracing on the homescreen
                """
            }

            // locate the 'Turn back on' button and tap
            XCTAssert(homeScreen.turnContactTracingBackOnButton.exists)
            XCTAssert(homeScreen.turnContactTracingBackOnButton.isHittable)
            homeScreen.turnContactTracingBackOnButton.tap()

            // check the button is gone
            XCTAssertFalse(homeScreen.turnContactTracingBackOnButton.exists)

            runner.step("Contact tracing on") {
                """
                User now sees that contact tracing is back on
                """
            }
        }
    }
}
