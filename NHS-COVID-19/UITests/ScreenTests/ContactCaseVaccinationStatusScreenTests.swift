//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class ContactCaseVaccinationStatusScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<ContactCaseVaccinationStatusScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = ContactCaseVaccinationStatusScreen(app: app, lastDoseDate: runner.scenario.vaccineThresholdDate)
            XCTAssertTrue(screen.title.exists)
            XCTAssertTrue(screen.heading.exists)
            XCTAssertTrue(screen.description.exists)
            XCTAssertTrue(screen.fullyVaccinatedQuestion.exists)
            XCTAssertTrue(screen.fullyVaccinatedDescription.exists)
            XCTAssertTrue(screen.readMoreAboutVaccinesLink.exists)
            XCTAssertTrue(screen.yesFullyVaccinatedRadioButton(selected: false).exists)
            XCTAssertTrue(screen.noFullyVaccinatedRadioButton(selected: false).exists)
            XCTAssertTrue(screen.confirmButton.exists)
            
            XCTAssertFalse(screen.error.exists)
            XCTAssertFalse(screen.yesFullyVaccinatedRadioButton(selected: true).exists)
            XCTAssertFalse(screen.noFullyVaccinatedRadioButton(selected: true).exists)
            
            XCTAssertFalse(screen.lastDoseDateQuestion.exists)
            XCTAssertFalse(screen.yesLastDoseDateRadioButton(selected: false).exists)
            XCTAssertFalse(screen.noLastDoseDateRadioButton(selected: false).exists)
            XCTAssertFalse(screen.yesLastDoseDateRadioButton(selected: true).exists)
            XCTAssertFalse(screen.noLastDoseDateRadioButton(selected: true).exists)
        }
    }
    
    func testReadMoreAboutVaccinesLinkButton() throws {
        try runner.run { app in
            let screen = ContactCaseVaccinationStatusScreen(app: app, lastDoseDate: runner.scenario.vaccineThresholdDate)
            XCTAssertTrue(screen.readMoreAboutVaccinesLink.isHittable)
            screen.readMoreAboutVaccinesLink.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.linkTapped].exists)
        }
    }
    
    func testYesFullyVaccinatedButton() throws {
        try runner.run { app in
            let screen = ContactCaseVaccinationStatusScreen(app: app, lastDoseDate: runner.scenario.vaccineThresholdDate)
            screen.yesFullyVaccinatedRadioButton(selected: false).tap()
            XCTAssertTrue(screen.yesFullyVaccinatedRadioButton(selected: true).exists)
            
            XCTAssertTrue(screen.lastDoseDateQuestion.exists)
            XCTAssertTrue(screen.yesLastDoseDateRadioButton(selected: false).exists)
            XCTAssertTrue(screen.noLastDoseDateRadioButton(selected: false).exists)
        }
    }
    
    func testNoFullyVaccinatedButton() throws {
        try runner.run { app in
            let screen = ContactCaseVaccinationStatusScreen(app: app, lastDoseDate: runner.scenario.vaccineThresholdDate)
            screen.noFullyVaccinatedRadioButton(selected: false).tap()
            XCTAssertTrue(screen.noFullyVaccinatedRadioButton(selected: true).exists)
            
            XCTAssertTrue(screen.confirmButton.isHittable)
            screen.confirmButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.confirmNotFullyVaccinatedTapped].exists)
        }
    }
    
    func testYesLastDoseDateButton() throws {
        try runner.run { app in
            let screen = ContactCaseVaccinationStatusScreen(app: app, lastDoseDate: runner.scenario.vaccineThresholdDate)
            screen.yesFullyVaccinatedRadioButton(selected: false).tap()
            XCTAssertTrue(screen.yesFullyVaccinatedRadioButton(selected: true).exists)
            
            XCTAssertTrue(screen.lastDoseDateQuestion.exists)
            XCTAssertTrue(screen.yesLastDoseDateRadioButton(selected: false).exists)
            XCTAssertTrue(screen.noLastDoseDateRadioButton(selected: false).exists)
            
            app.scrollTo(element: screen.yesLastDoseDateRadioButton(selected: false))
            screen.yesLastDoseDateRadioButton(selected: false).tap()
            XCTAssertTrue(screen.yesLastDoseDateRadioButton(selected: true).exists)
            
            app.scrollTo(element: screen.confirmButton)
            screen.confirmButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.confirmFullyVaccinatedTapped].exists)
        }
    }
    
    func testNoLastDoseDateButton() throws {
        try runner.run { app in
            let screen = ContactCaseVaccinationStatusScreen(app: app, lastDoseDate: runner.scenario.vaccineThresholdDate)
            screen.yesFullyVaccinatedRadioButton(selected: false).tap()
            XCTAssertTrue(screen.yesFullyVaccinatedRadioButton(selected: true).exists)
            
            XCTAssertTrue(screen.lastDoseDateQuestion.exists)
            XCTAssertTrue(screen.yesLastDoseDateRadioButton(selected: false).exists)
            XCTAssertTrue(screen.noLastDoseDateRadioButton(selected: false).exists)
            
            app.scrollTo(element: screen.noLastDoseDateRadioButton(selected: false))
            screen.noLastDoseDateRadioButton(selected: false).tap()
            XCTAssertTrue(screen.noLastDoseDateRadioButton(selected: true).exists)
            
            app.scrollTo(element: screen.confirmButton)
            screen.confirmButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.confirmNotFullyVaccinatedTapped].exists)
        }
    }
    
    func testHidingOfLastDoseDateRadioButtonGroup() throws {
        try runner.run { app in
            let screen = ContactCaseVaccinationStatusScreen(app: app, lastDoseDate: runner.scenario.vaccineThresholdDate)
            screen.yesFullyVaccinatedRadioButton(selected: false).tap()
            XCTAssertTrue(screen.yesFullyVaccinatedRadioButton(selected: true).exists)
            
            XCTAssertTrue(screen.lastDoseDateQuestion.exists)
            XCTAssertTrue(screen.yesLastDoseDateRadioButton(selected: false).exists)
            XCTAssertTrue(screen.noLastDoseDateRadioButton(selected: false).exists)
            
            app.scrollTo(element: screen.yesLastDoseDateRadioButton(selected: false))
            screen.yesLastDoseDateRadioButton(selected: false).tap()
            XCTAssertTrue(screen.yesLastDoseDateRadioButton(selected: true).exists)
            
            // hide the second radio button group
            screen.noFullyVaccinatedRadioButton(selected: false).tap()
            XCTAssertTrue(screen.noFullyVaccinatedRadioButton(selected: true).exists)
            
            XCTAssertFalse(screen.lastDoseDateQuestion.exists)
            XCTAssertFalse(screen.yesLastDoseDateRadioButton(selected: false).exists)
            XCTAssertFalse(screen.noLastDoseDateRadioButton(selected: false).exists)
            XCTAssertFalse(screen.yesLastDoseDateRadioButton(selected: true).exists)
            XCTAssertFalse(screen.noLastDoseDateRadioButton(selected: true).exists)
        }
    }
    
    func testResetSelectionOfLastDoseDateRadioButtonGroup() throws {
        try runner.run { app in
            let screen = ContactCaseVaccinationStatusScreen(app: app, lastDoseDate: runner.scenario.vaccineThresholdDate)
            screen.yesFullyVaccinatedRadioButton(selected: false).tap()
            XCTAssertTrue(screen.yesFullyVaccinatedRadioButton(selected: true).exists)
            
            XCTAssertTrue(screen.lastDoseDateQuestion.exists)
            XCTAssertTrue(screen.yesLastDoseDateRadioButton(selected: false).exists)
            XCTAssertTrue(screen.noLastDoseDateRadioButton(selected: false).exists)
            
            app.scrollTo(element: screen.yesLastDoseDateRadioButton(selected: false))
            screen.yesLastDoseDateRadioButton(selected: false).tap()
            XCTAssertTrue(screen.yesLastDoseDateRadioButton(selected: true).exists)
            
            // hide the second radio button group
            screen.noFullyVaccinatedRadioButton(selected: false).tap()
            XCTAssertTrue(screen.noFullyVaccinatedRadioButton(selected: true).exists)
            
            XCTAssertFalse(screen.lastDoseDateQuestion.exists)
            XCTAssertFalse(screen.yesLastDoseDateRadioButton(selected: false).exists)
            XCTAssertFalse(screen.noLastDoseDateRadioButton(selected: false).exists)
            XCTAssertFalse(screen.yesLastDoseDateRadioButton(selected: true).exists)
            XCTAssertFalse(screen.noLastDoseDateRadioButton(selected: true).exists)
            
            // show the second radio button group again
            screen.yesFullyVaccinatedRadioButton(selected: false).tap()
            XCTAssertTrue(screen.yesFullyVaccinatedRadioButton(selected: true).exists)
            
            // buttons of LastDoseDateRadioButtonGroup should be unselected
            XCTAssertTrue(screen.lastDoseDateQuestion.exists)
            XCTAssertTrue(screen.yesLastDoseDateRadioButton(selected: false).exists)
            XCTAssertTrue(screen.noLastDoseDateRadioButton(selected: false).exists)
            XCTAssertFalse(screen.yesLastDoseDateRadioButton(selected: true).exists)
            XCTAssertFalse(screen.noLastDoseDateRadioButton(selected: true).exists)
        }
    }
    
    func testErrorAppearanceWhenNoButtonsAreSelected() throws {
        try runner.run { app in
            let screen = ContactCaseVaccinationStatusScreen(app: app, lastDoseDate: runner.scenario.vaccineThresholdDate)
            screen.confirmButton.tap()
            XCTAssertTrue(screen.error.exists)
        }
    }
    
    func testErrorAppearanceWhenYesFullyVaccinatedButtonIsSelected() throws {
        try runner.run { app in
            let screen = ContactCaseVaccinationStatusScreen(app: app, lastDoseDate: runner.scenario.vaccineThresholdDate)
            
            screen.yesFullyVaccinatedRadioButton(selected: false).tap()
            XCTAssertTrue(screen.yesFullyVaccinatedRadioButton(selected: true).exists)
            
            screen.confirmButton.tap()
            XCTAssertTrue(screen.error.exists)
        }
    }
    
    func testErrorDisappearanceWhenNoFullyVaccinatedButtonIsSelected() throws {
        try runner.run { app in
            let screen = ContactCaseVaccinationStatusScreen(app: app, lastDoseDate: runner.scenario.vaccineThresholdDate)
            screen.confirmButton.tap()
            XCTAssertTrue(screen.error.exists)
            
            screen.noFullyVaccinatedRadioButton(selected: false).tap()
            screen.confirmButton.tap()
            XCTAssertFalse(screen.error.exists)
        }
    }
    
    func testErrorDisappearanceWhenYesLastDoseDateButtonIsSelected() throws {
        try runner.run { app in
            let screen = ContactCaseVaccinationStatusScreen(app: app, lastDoseDate: runner.scenario.vaccineThresholdDate)
            screen.confirmButton.tap()
            XCTAssertTrue(screen.error.exists)
            
            screen.yesFullyVaccinatedRadioButton(selected: false).tap()
            XCTAssertTrue(screen.yesFullyVaccinatedRadioButton(selected: true).exists)
            
            XCTAssertTrue(screen.lastDoseDateQuestion.exists)
            XCTAssertTrue(screen.yesLastDoseDateRadioButton(selected: false).exists)
            XCTAssertTrue(screen.noLastDoseDateRadioButton(selected: false).exists)
            
            app.scrollTo(element: screen.yesLastDoseDateRadioButton(selected: false))
            screen.yesLastDoseDateRadioButton(selected: false).tap()
            
            app.scrollTo(element: screen.confirmButton)
            screen.confirmButton.tap()
            XCTAssertFalse(screen.error.exists)
        }
    }
    
}
