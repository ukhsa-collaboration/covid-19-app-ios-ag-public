//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class SuccessHomeScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<SuccessHomeScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = HomeScreen(app: app)
            XCTAssert(screen.riskLevelBanner(for: "SW12", title: "[postcode] is in Local Alert Level 1").exists)
            XCTAssert(screen.notIsolatingIndicator.exists)
        }
    }
    
    func testMoreInfoButton() throws {
        try runner.run { app in
            let screen = HomeScreen(app: app)
            
            let moreInfoButtonAction = app.staticTexts[HomeScreenAlerts.postcodeBannerAlertTitle]
            
            app.scrollTo(element: screen.riskLevelBanner(for: "SW12", title: "[postcode] is in Local Alert Level 1"))
            screen.riskLevelBanner(for: "SW12", title: "[postcode] is in Local Alert Level 1").tap()
            XCTAssert(moreInfoButtonAction.displayed)
        }
    }
    
    func testAboutButton() throws {
        try runner.run { app in
            let screen = HomeScreen(app: app)
            
            let aboutAction = app.staticTexts[HomeScreenAlerts.aboutAlertTitle]
            app.scrollTo(element: screen.aboutButton)
            screen.aboutButton.tap()
            XCTAssert(aboutAction.displayed)
        }
    }
    
    func testDiagnosisButton() throws {
        try runner.run { app in
            let screen = HomeScreen(app: app)
            
            let diagnosisButtonAction = app.staticTexts[HomeScreenAlerts.diagnosisAlertTitle]
            app.scrollTo(element: screen.diagnoisButton)
            screen.diagnoisButton.tap()
            XCTAssert(diagnosisButtonAction.displayed)
        }
    }
    
    func testExposureNotificationToggle() throws {
        try runner.run { app in
            let screen = HomeScreen(app: app)
            
            let exposureToggleAction = app.staticTexts[HomeScreenAlerts.exposureNotificationAlertTitle]
            screen.exposureNotificationSwitch.tap()
            XCTAssert(exposureToggleAction.displayed)
        }
    }
    
    func testAdviceButton() throws {
        try runner.run { app in
            let screen = HomeScreen(app: app)
            
            let adviceButtonAction = app.staticTexts[HomeScreenAlerts.adviceAlertTitle]
            app.scrollTo(element: screen.adviceButton)
            screen.adviceButton.tap()
            XCTAssert(adviceButtonAction.displayed)
        }
    }
    
    func testTestingInformationButton() throws {
        try runner.run { app in
            let screen = HomeScreen(app: app)
            
            let testingInformationButtonAction = app.staticTexts[HomeScreenAlerts.testingInformationAlertTitle]
            app.scrollTo(element: screen.testingInformationButton)
            screen.testingInformationButton.tap()
            XCTAssert(testingInformationButtonAction.displayed)
        }
    }
    
    func testFinanceButton() throws {
        try runner.run { app in
            let screen = HomeScreen(app: app)
            
            let financeButtonAction = app.staticTexts[HomeScreenAlerts.financeAlertTitle]
            app.scrollTo(element: screen.financeButton)
            screen.financeButton.tap()
            XCTAssert(financeButtonAction.displayed)
        }
    }
    
    func testSettingsButton() throws {
        try runner.run { app in
            let screen = HomeScreen(app: app)
            
            let settingsButtonAction = app.staticTexts[HomeScreenAlerts.settingsAlertTitle]
            app.scrollTo(element: screen.settingsButton)
            screen.settingsButton.tap()
            XCTAssert(settingsButtonAction.displayed)
        }
    }
}

class DisabledFeaturesHomeScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<DisabledFeaturesHomeScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = HomeScreen(app: app)
            XCTAssertFalse(screen.riskLevelBanner(for: "SW12", title: "[postcode] is in Local Alert Level 1").exists)
            XCTAssertFalse(screen.diagnoisButton.exists)
            XCTAssertFalse(screen.testingInformationButton.exists)
        }
    }
    
    func testAdviceButton() throws {
        try runner.run { app in
            let screen = HomeScreen(app: app)
            
            let adviceButtonAction = app.staticTexts[HomeScreenAlerts.adviceAlertTitle]
            app.scrollTo(element: screen.adviceButton)
            screen.adviceButton.tap()
            XCTAssert(adviceButtonAction.displayed)
        }
    }
}
