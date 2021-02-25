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
        $runner.initialState.localAuthorityId = "Sheffield"
    }
    
    func testEditPostCodeAndLocalAuthorityWithoutLocalAuthoritySelection() throws {
        
        let newPostcode = "S1"
        let localAuhtority = "Sheffield"
        
        $runner.report(scenario: "Edit postcode", "Happy path - confirm local authority") {
            """
            Enter a valid new postcode, confirm the local authority and reach My Data screen again.
            """
        }
        
        try runner.run { app in
            
            let homeScreen = HomeScreen(app: app)
            app.checkOnHomeScreenNotIsolating()
            XCTAssert(homeScreen.aboutButton.exists)
            
            runner.step("Home screen") {
                """
                The user is presented the Home screen.
                The user presses the About This App entry to proceed.
                """
            }
            
            app.scrollTo(element: homeScreen.aboutButton)
            homeScreen.aboutButton.tap()
            
            let aboutThisAppScreen = AboutThisAppScreen(app: app)
            XCTAssert(aboutThisAppScreen.seeDataButton.exists)
            
            runner.step("About This App screen") {
                """
                The user is presented the About This App screen.
                The user presses the Manage My Data link to proceed.
                """
            }
            
            aboutThisAppScreen.seeDataButton.tap()
            
            let myDataScreen = MyDataScreen(app: app)
            XCTAssert(myDataScreen.editPostcodeButton.exists)
            
            runner.step("My Data screen") {
                """
                The user is presented the My Data screen.
                The user presses the Edit button of the postcode section.
                """
            }
            
            myDataScreen.editPostcodeButton.tap()
            
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
            
            let myDataScreenNewPostcode = MyDataScreen(app: app)
            let postcodeCellElements = myDataScreenNewPostcode.postcodeAndLocalAuthorityCell(postcode: newPostcode, localAuthority: localAuhtority)
            XCTAssert(postcodeCellElements[0].exists)
            XCTAssert(postcodeCellElements[1].exists)
            
            runner.step("My Data screen - new postcode and local authority") {
                """
                The user is presented the My Data screen again with the newly entered postcode and confirmed local authority.
                """
            }
        }
    }
    
    func testEditPostCodeAndLocalAuthorityWithLocalAuthoritySelection() throws {
        let newPostcode = "LL20"
        let localAuhtority = "Wrexham / Wrecsam"
        
        $runner.report(scenario: "Edit postcode", "Happy path - select local authority") {
            """
            Enter a valid new postcode, select the local authority and reach My Data screen again.
            """
        }
        
        try runner.run { app in
            
            let homeScreen = HomeScreen(app: app)
            app.checkOnHomeScreenNotIsolating()
            XCTAssert(homeScreen.aboutButton.exists)
            
            runner.step("Home screen") {
                """
                The user is presented the Home screen.
                The user presses the About This App entry to proceed.
                """
            }
            
            app.scrollTo(element: homeScreen.aboutButton)
            homeScreen.aboutButton.tap()
            
            let aboutThisAppScreen = AboutThisAppScreen(app: app)
            XCTAssert(aboutThisAppScreen.seeDataButton.exists)
            
            runner.step("About This App screen") {
                """
                The user is presented the About This App screen.
                The user presses the Manage My Data link to proceed.
                """
            }
            
            aboutThisAppScreen.seeDataButton.tap()
            
            let myDataScreen = MyDataScreen(app: app)
            XCTAssert(myDataScreen.editPostcodeButton.exists)
            
            runner.step("My Data screen") {
                """
                The user is presented the My Data screen.
                The user presses the Edit button of the postcode section.
                """
            }
            
            myDataScreen.editPostcodeButton.tap()
            
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
            
            localAuthorityScreen.localAuthorityCard(checked: false, title: localAuhtority).tap()
            
            runner.step("Your Local Authority screen - selected local authority") {
                """
                The user is presented the Your Local Authority screen with the selected local authority.
                 The user presses the confirm button.
                """
            }
            
            app.scrollTo(element: localAuthorityScreen.button)
            localAuthorityScreen.button.tap()
            
            let myDataScreenNewPostcode = MyDataScreen(app: app)
            let postcodeCellElements = myDataScreenNewPostcode.postcodeAndLocalAuthorityCell(postcode: newPostcode, localAuthority: localAuhtority)
            XCTAssert(postcodeCellElements[0].exists)
            XCTAssert(postcodeCellElements[1].exists)
            
            runner.step("My Data screen -  new postcode and select local authority") {
                """
                The user is presented the My Data screen with the new postcode and the selected local authority.
                """
            }
        }
    }
}
