//
// Copyright © 2021 DHSC. All rights reserved.
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
            XCTAssert(screen.localInfoBanner(text: "A new variant of concern is in your area.").exists)
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

    func testTapOnLocalInfoBanner() throws {
        try runner.run { app in
            let screen = HomeScreen(app: app)

            let localInfoBanner = screen.localInfoBanner(text: "A new variant of concern is in your area.")
            app.scrollTo(element: localInfoBanner)
            localInfoBanner.tap()

            let localInfoBannerAction = app.staticTexts[HomeScreenAlerts.localInfoBannerAlertTitle]
            XCTAssert(localInfoBannerAction.displayed)
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
            app.scrollTo(element: screen.selfDiagnosisButton)
            screen.selfDiagnosisButton.tap()
            XCTAssert(diagnosisButtonAction.displayed)
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

    func testContactTracingHubButton() throws {
        try runner.run { app in
            let screen = HomeScreen(app: app)

            let contactTracingHubButtonAction = app.staticTexts[HomeScreenAlerts.contactTracingHubAlertTitle]
            app.scrollTo(element: screen.contactTracingHubButton)
            screen.contactTracingHubButton.tap()
            XCTAssert(contactTracingHubButtonAction.displayed)
        }
    }

    func testTestingHubButton() throws {
        try runner.run { app in
            let screen = HomeScreen(app: app)

            let testingHubButtonAction = app.staticTexts[HomeScreenAlerts.testingHubAlertTitle]
            app.scrollTo(element: screen.testingHubButton)
            screen.testingHubButton.tap()
            XCTAssert(testingHubButtonAction.displayed)
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
            XCTAssertFalse(screen.selfDiagnosisButton.exists)
            XCTAssertFalse(screen.localInfoBanner(text: "A new variant of concern is in your area.").exists)
        }
    }

}
