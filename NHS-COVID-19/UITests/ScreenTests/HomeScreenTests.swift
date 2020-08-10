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
            XCTAssert(screen.aboutButton.exists)
            XCTAssert(screen.riskLevelBanner.exists)
        }
    }
    
    func testMoreInfoButton() throws {
        try runner.run { app in
            let screen = HomeScreen(app: app)
            
            let moreInfoButtonAction = app.staticTexts[HomeScreenAlerts.moreInfoAlertTitle]
            
            app.scrollTo(element: screen.moreInfoButton)
            screen.moreInfoButton.tap()
            XCTAssert(moreInfoButtonAction.displayed)
        }
    }
    
    func testAboutContactTracing() throws {
        try runner.run { app in
            let screen = HomeScreen(app: app)
            
            let aboutContactTracingAction = app.staticTexts[HomeScreenAlerts.contactTracingAlertTitle]
            app.scrollTo(element: screen.aboutTracingButton)
            screen.aboutTracingButton.tap()
            XCTAssert(aboutContactTracingAction.displayed)
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
            XCTAssertFalse(screen.riskLevelBanner.exists)
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
