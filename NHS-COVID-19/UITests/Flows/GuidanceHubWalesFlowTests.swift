//
// Copyright © 2022 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class GuidanceHubWalesFlowTests: XCTestCase {
    @Propped
    private var runner: ApplicationRunner<SandboxedScenario>
    
    override func setUp() {
        $runner.initialState.exposureNotificationsAuthorized = true
        $runner.initialState.userNotificationsAuthorized = false
        $runner.initialState.postcode = "LL61"
        $runner.initialState.localAuthorityId = "W06000001"
    }

    func testCovidGuidanceHubIsReachable() throws {
        $runner.enable(\.$guidanceHubWalesToggle)
        
        $runner.report(scenario: "COVID-19 Guidance Hub (Wales)", "Happy path") {
            """
            As an app user in Wales, you can access a centralised source of information and further actions and guidance on how to live with COVID-19
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

            let guidanceHubScreen = GuidanceHubWalesScreen(app: app)
            
            for element in guidanceHubScreen.allElements {
                app.scrollTo(element: element)
                XCTAssertTrue(element.exists)
            }
            

        }
    }
    
}

