//
// Copyright © 2022 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class GuidanceHubEnglandFlowTests: XCTestCase {
    @Propped
    private var runner: ApplicationRunner<SandboxedScenario>

    override func setUp() {
        $runner.initialState.exposureNotificationsAuthorized = true
        $runner.initialState.userNotificationsAuthorized = false
        $runner.initialState.postcode = "S1"
        $runner.initialState.localAuthorityId = "E08000019"
    }

    func testCovidGuidanceHub() throws {
        $runner.enable(\.$guidanceHubEnglandToggle)

        $runner.report(scenario: "COVID-19 Guidance Hub (England)", "Happy path") {
            """
            As an English app user, you can access a centralised source of information and further actions and guidance on how to live with COVID-19
            """
        }

        try runner.run { app in

            let homeScreen = HomeScreen(app: app)
            app.checkOnHomeScreen(with: homeScreen.guidanceHubButton)

            runner.step("Home screen") {
                """
                The user is presented the Home screen.
                The user presses the COVID-19 Guidance button.
                """
            }

            homeScreen.guidanceHubButton.tap()

            runner.step("Guidance Hub screen") {
                """
                The user is presented the Guidance Hub screen.
                """
            }

            let guidanceHubScreen = GuidanceHubEnglandScreen(app: app)
            XCTAssertTrue(guidanceHubScreen.covidGuidanceForEnglandButton.exists)

        }
    }

}

