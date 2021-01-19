//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class LocalAuthorityFlowTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<SandboxedScenario>
    
    override func setUp() {
        $runner.initialState.exposureNotificationsAuthorized = true
        $runner.initialState.userNotificationsAuthorized = false
    }
    
    func testSelectLocalAuthority() throws {
        $runner.initialState.postcode = "ST15"
        $runner.report(scenario: "Confirm Local Authority", "Happy path - Select local authority") {
            """
            Inform about the need of a local authority, choose a local authority from the list, and reach home screen.
            """
        }
        
        try runner.run { app in
            
            let informationScreen = LocalAuthorityScreen(app: app)
            XCTAssert(informationScreen.title.exists)
            
            runner.step("Local authority information screen") {
                """
                The user is shown an information that their local authority is needed
                """
            }
            
            informationScreen.button.tap()
            
            let localAuthorityScreen = SelectLocalAuthorityScreen(app: app)
            XCTAssert(localAuthorityScreen.linkBtn.exists)
            
            runner.step("Local authority screen") {
                """
                The user is asked to select a local authority.
                """
            }
            
            localAuthorityScreen.localAuthorityCard(checked: false, title: "Stafford").tap()
            
            runner.step("Local authority screen - select authority") {
                """
                The user selects their local authority, then continues.
                """
            }
            
            localAuthorityScreen.button.tap()
            
            runner.step("Home Screen") {
                """
                The user is presented the Home screen.
                """
            }
            
            app.checkOnHomeScreenNotIsolating()
        }
    }
    
    func testConfirmLocalAuthority() throws {
        $runner.initialState.postcode = "S1"
        $runner.report(scenario: "Confirm Local Authority", "Happy path - Single local authority") {
            """
            Inform about the need of a local authority, confirm the local authority, and reach home screen.
            """
        }
        
        try runner.run { app in
            
            let informationScreen = LocalAuthorityScreen(app: app)
            XCTAssert(informationScreen.title.exists)
            
            runner.step("Local authority information screen") {
                """
                The user is shown an information that their local authority is needed
                """
            }
            
            informationScreen.button.tap()
            
            let localAuthorityConfirmationScreen = LocalAuthorityConfirmationScreen(app: app)
            XCTAssert(localAuthorityConfirmationScreen.title.exists)
            
            runner.step("Local authority screen") {
                """
                The user is asked to select a local authority.
                """
            }
            
            localAuthorityConfirmationScreen.button.tap()
            
            runner.step("Home Screen") {
                """
                The user is presented the Home screen.
                """
            }
            
            app.checkOnHomeScreenNotIsolating()
        }
    }
}
