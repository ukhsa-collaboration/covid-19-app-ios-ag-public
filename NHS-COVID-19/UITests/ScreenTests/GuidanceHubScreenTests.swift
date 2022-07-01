//
// Copyright © 2022 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class GuidanceHubScreenTests: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<GuidanceHubEnglandScreenScenario>

    func testBasics() throws {
        try runner.run { app in
            let screen = GuidanceHubEnglandScreen(app: app)

            XCTAssertTrue(screen.covidGuidanceForEnglandButton.exists)
            XCTAssertTrue(screen.checkSymptomsButton.exists)
            XCTAssertTrue(screen.latestGuidanceButton.exists)
            XCTAssertTrue(screen.positiveTestResultButton.exists)
            XCTAssertTrue(screen.travellingAbroadButton.exists)
            XCTAssertTrue(screen.checkSSPButton.exists)
            XCTAssertTrue(screen.covidEnquiriesButton.exists)
        }
    }

    func testCovidGuidanceForEnglandButton() throws {
        try runner.run { app in
            let screen = GuidanceHubEnglandScreen(app: app)
            app.scrollTo(element: screen.covidGuidanceForEnglandButton)
            screen.covidGuidanceForEnglandButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.covid19GuidanceForEnglandTitle].exists)
        }
    }

    func testCheckSymptomsButton() throws {
        try runner.run { app in
            let screen = GuidanceHubEnglandScreen(app: app)
            app.scrollTo(element: screen.checkSymptomsButton)
            screen.checkSymptomsButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.checkSymptomsForCovid19EnglandTitle].exists)
        }
    }

    func testLatestGuidanceButton() throws {
        try runner.run { app in
            let screen = GuidanceHubEnglandScreen(app: app)
            app.scrollTo(element: screen.latestGuidanceButton)
            screen.latestGuidanceButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.latestCovid19TestingGuidanceEnglandTitle].exists)
        }
    }

    func testPositiveTestResultButton() throws {
        try runner.run { app in
            let screen = GuidanceHubEnglandScreen(app: app)
            app.scrollTo(element: screen.positiveTestResultButton)
            screen.positiveTestResultButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.ifPositiveCovid19GuidanceEnglandTitle].exists)
        }
    }

    func testTravellingAbroadButton() throws {
        try runner.run { app in
            let screen = GuidanceHubEnglandScreen(app: app)
            app.scrollTo(element: screen.travellingAbroadButton)
            screen.travellingAbroadButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.travellingAbroadGuidanceEnglandTitle].exists)
        }
    }

    func testCheckSSPButton() throws {
        try runner.run { app in
            let screen = GuidanceHubEnglandScreen(app: app)
            app.scrollTo(element: screen.checkSSPButton)
            screen.checkSSPButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.claimSSPGuidanceEnglandTitle].exists)
        }
    }

    func testCovidEnquiriesButton() throws {
        try runner.run { app in
            let screen = GuidanceHubEnglandScreen(app: app)
            app.scrollTo(element: screen.covidEnquiriesButton)
            screen.covidEnquiriesButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.getHelpWithCovid19EnquiriesEnglandTitle].exists)
        }
    }
}
