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
            XCTAssert(screen.riskLevelBanner(for: "SW12", risk: localize(.risk_level_low)).exists)
            XCTAssert(screen.notIsolatingIndicator.exists)
        }
    }
    
    func testMoreInfoButton() throws {
        try runner.run { app in
            let screen = HomeScreen(app: app)
            
            let moreInfoButtonAction = app.staticTexts[HomeScreenAlerts.postcodeBannerAlertTitle]
            
            app.scrollTo(element: screen.riskLevelBanner(for: "SW12", risk: localize(.risk_level_low)))
            screen.riskLevelBanner(for: "SW12", risk: localize(.risk_level_low)).tap()
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
}

class DisabledFeaturesHomeScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<DisabledFeaturesHomeScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = HomeScreen(app: app)
            XCTAssertFalse(screen.riskLevelBanner(for: "SW12", risk: localize(.risk_level_low)).exists)
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
