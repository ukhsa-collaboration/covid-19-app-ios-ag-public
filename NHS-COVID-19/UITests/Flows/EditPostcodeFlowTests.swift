//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class EditPostcodeFlowTest: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<SandboxedScenario>
    
    override func setUp() {
        $runner.initialState.isPilotActivated = true
        $runner.initialState.exposureNotificationsAuthorized = true
        $runner.initialState.userNotificationsAuthorized = true
        $runner.initialState.postcode = "S1"
        $runner.initialState.localAuthorityId = "E08000019" // Sheffield
    }
    
    func testEditPostCodeAndLocalAuthorityWithoutLocalAuthoritySelection() throws {
        
        let newPostcode = "L4"
        let localAuthority = "Liverpool"
        
        $runner.report(scenario: "Edit postcode", "Happy path - confirm local authority") {
            """
            Enter a valid new postcode, confirm the local authority and reach My Area screen again.
            """
        }
        
        try runner.run { app in
            
            let homeScreen = HomeScreen(app: app)
            app.checkOnHomeScreenNotIsolating()
            XCTAssert(homeScreen.settingsButton.exists)
            
            runner.step("Home screen") {
                """
                The user is presented the Home screen.
                The user presses the Settings to continue.
                """
            }
            
            app.scrollTo(element: homeScreen.settingsButton)
            homeScreen.settingsButton.tap()
            
            let settingsScreen = SettingsScreen(app: app)
            XCTAssert(settingsScreen.myAreaRow.exists)
            
            runner.step("Settings screen") {
                """
                The user is presented the Settings screen.
                The user presses the My Area button to proceed.
                """
            }
            
            settingsScreen.myAreaRow.tap()
            
            let myAreaScreen = MyAreaScreen(app: app)
            XCTAssert(myAreaScreen.edit.exists)
            
            XCTAssert(myAreaScreen.postcodeCellValue(postcode: "S1").exists)
            XCTAssert(myAreaScreen.localAuthorityCellValue(localAuthority: "Sheffield").exists)
            
            runner.step("My Area screen") {
                """
                The user is presented the My Area screen.
                The user presses the Edit button.
                """
            }
            
            myAreaScreen.edit.tap()
            
            let editPostcodeScreen = EditPostcodeScreen(app: app)
            XCTAssert(editPostcodeScreen.continueButton.exists)
            
            runner.step("Edit Postcode screen") {
                """
                The user is presented the Edit Postcode screen.
                """
            }
            
            editPostcodeScreen.postcodeTextField.tap()
            editPostcodeScreen.postcodeTextField.typeText(newPostcode)
            
            runner.step("Edit Postcode screen - entered postcode") {
                """
                The user enters a new valid postcode in the field.
                The user presses the Continue button.
                """
            }
            
            editPostcodeScreen.continueButton.tap()
            
            let localAuthorityConfirmationScreen = LocalAuthorityConfirmationScreen(app: app)
            XCTAssert(localAuthorityConfirmationScreen.title.exists)
            
            runner.step("Your Local Authority screen") {
                """
                The user is presented the Your Local Authority screen with the mapped local authority.
                The user presses the confirm button.
                """
            }
            
            localAuthorityConfirmationScreen.button.tap()
            
            let myAreaScreenNewPostcodeAndLocalAuthority = MyAreaScreen(app: app)
            XCTAssert(myAreaScreenNewPostcodeAndLocalAuthority.postcodeCellValue(postcode: newPostcode).exists)
            XCTAssert(myAreaScreenNewPostcodeAndLocalAuthority.localAuthorityCellValue(localAuthority: localAuthority).exists)
            
            runner.step("My Area screen - new postcode and local authority") {
                """
                The user is presented the My Area screen again with the newly entered postcode and confirmed local authority.
                """
            }
            
        }
    }
    
    func testEditPostCodeAndLocalAuthorityWithLocalAuthoritySelection() throws {
        
        let newPostcode = "LL20"
        let localAuthority = "Wrexham / Wrecsam"
        
        $runner.report(scenario: "Edit postcode", "Happy path - select local authority") {
            """
            Enter a valid new postcode, select the local authority and reach My Area screen again.
            """
        }
        
        try runner.run { app in
            
            let homeScreen = HomeScreen(app: app)
            app.checkOnHomeScreenNotIsolating()
            XCTAssert(homeScreen.settingsButton.exists)
            
            runner.step("Home screen") {
                """
                The user is presented the Home screen.
                The user presses the Settings to continue.
                """
            }
            
            app.scrollTo(element: homeScreen.settingsButton)
            homeScreen.settingsButton.tap()
            
            let settingsScreen = SettingsScreen(app: app)
            XCTAssert(settingsScreen.myAreaRow.exists)
            
            runner.step("Settings screen") {
                """
                The user is presented the Settings screen.
                The user presses the My Area button to proceed.
                """
            }
            
            settingsScreen.myAreaRow.tap()
            
            let myAreaScreen = MyAreaScreen(app: app)
            XCTAssert(myAreaScreen.edit.exists)
            
            XCTAssert(myAreaScreen.postcodeCellValue(postcode: "S1").exists)
            XCTAssert(myAreaScreen.localAuthorityCellValue(localAuthority: "Sheffield").exists)
            
            runner.step("My Area screen") {
                """
                The user is presented the My Area screen.
                The user presses the Edit button.
                """
            }
            
            myAreaScreen.edit.tap()
            
            let editPostcodeScreen = EditPostcodeScreen(app: app)
            XCTAssert(editPostcodeScreen.continueButton.exists)
            
            runner.step("Edit Postcode screen") {
                """
                The user is presented to Edit Postcode screen.
                """
            }
            
            editPostcodeScreen.postcodeTextField.tap()
            editPostcodeScreen.postcodeTextField.typeText(newPostcode)
            
            runner.step("Edit Postcode screen - entered postcode") {
                """
                The user enters a new valid postcode in the field.
                The user presses the continue button.
                """
            }
            
            editPostcodeScreen.continueButton.tap()
            
            let localAuthorityScreen = SelectLocalAuthorityScreen(app: app)
            XCTAssert(localAuthorityScreen.linkBtn.exists)
            
            runner.step("Your Local Authority screen") {
                """
                The user is presented the Your Local Authority screen.
                The user selects a local authority.
                """
            }
            
            localAuthorityScreen.localAuthorityCard(checked: false, title: localAuthority).tap()
            
            runner.step("Your Local Authority screen - selected local authority") {
                """
                The user is presented the Your Local Authority screen with the selected local authority.
                 The user presses the confirm button.
                """
            }
            
            app.scrollTo(element: localAuthorityScreen.button)
            localAuthorityScreen.button.tap()
            
            let myAreaScreenNewPostcodeAndLocalAuthority = MyAreaScreen(app: app)
            XCTAssert(myAreaScreenNewPostcodeAndLocalAuthority.postcodeCellValue(postcode: newPostcode).exists)
            XCTAssert(myAreaScreenNewPostcodeAndLocalAuthority.localAuthorityCellValue(localAuthority: localAuthority).exists)
            
            runner.step("My Area screen - new postcode and local authority") {
                """
                The user is presented the My Area screen again with the newly entered postcode and confirmed local authority.
                """
            }
            
        }
    }
}
