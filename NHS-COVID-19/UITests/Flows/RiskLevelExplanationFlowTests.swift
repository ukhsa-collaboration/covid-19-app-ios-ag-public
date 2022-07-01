//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class RiskLevelExplanationFlowTests: XCTestCase {
    @Propped
    private var runner: ApplicationRunner<SandboxedScenario>

    override func setUp() {
        $runner.initialState.exposureNotificationsAuthorized = true
        $runner.initialState.userNotificationsAuthorized = true
    }

    func testNeutralPath() throws {
        let postcode = "SW16"
        $runner.initialState.postcode = postcode
        $runner.initialState.localAuthorityId = "E09000026"

        $runner.report(scenario: "Area risk level", "Neutral risk (low)") {
            """
            Users see the home screen with neutral risk and navigate to risk level alert info
            """
        }
        try runner.run { app in
            let homeScreen = HomeScreen(app: app)

            app.checkOnHomeScreen(postcode: postcode)

            runner.step("Home Screen") {
                """
                When the user is on the Home screen and can tap on risk level banner
                """
            }

            homeScreen.riskLevelBanner(for: postcode, title: "[postcode] is in Local Alert Level 1").tap()

            runner.step("Risk level info") {
                """
                Users is on Risk level info screen
                """
            }
        }
    }

    func testGreenPath() throws {
        let postcode = "SW12"
        $runner.initialState.postcode = postcode
        $runner.initialState.localAuthorityId = "E09000022"

        $runner.report(scenario: "Area risk level", "Green risk (low)") {
            """
            Users see the home screen with green risk and navigate to risk level alert info
            """
        }
        try runner.run { app in
            let homeScreen = HomeScreen(app: app)

            app.checkOnHomeScreen(postcode: postcode)

            runner.step("Home Screen") {
                """
                When the user is on the Home screen and can tap on risk level banner
                """
            }

            homeScreen.riskLevelBanner(for: postcode, title: "[postcode] is in Local Alert Level 1").tap()

            runner.step("Risk level info") {
                """
                Users is on Risk level info screen
                """
            }
        }
    }

    func testYellowPath() throws {
        let postcode = "SW14"
        $runner.initialState.postcode = postcode
        $runner.initialState.localAuthorityId = "E09000024"

        $runner.report(scenario: "Area risk level", "Yellow risk (medium)") {
            """
            Users see the home screen with yellow risk and navigate to risk level alert info
            """
        }
        try runner.run { app in
            let homeScreen = HomeScreen(app: app)

            app.checkOnHomeScreen(postcode: postcode, alertLevel: 2)

            runner.step("Home Screen") {
                """
                When the user is on the Home screen and can tap on risk level banner
                """
            }

            homeScreen.riskLevelBanner(for: postcode, title: "[postcode] is in Local Alert Level 2").tap()

            runner.step("Risk level info") {
                """
                Users is on Risk level info screen
                """
            }
        }
    }

    func testAmberPath() throws {
        let postcode = "SW13"
        $runner.initialState.postcode = postcode
        $runner.initialState.localAuthorityId = "E09000023"

        $runner.report(scenario: "Area risk level", "Amber risk (medium)") {
            """
            Users see the home screen with amber risk and navigate to risk level alert info
            """
        }
        try runner.run { app in
            let homeScreen = HomeScreen(app: app)

            app.checkOnHomeScreen(postcode: postcode, alertLevel: 3)

            runner.step("Home Screen") {
                """
                When the user is on the Home screen and can tap on risk level banner
                """
            }

            homeScreen.riskLevelBanner(for: postcode, title: "[postcode] is in Local Alert Level 3").tap()

            runner.step("Risk level info") {
                """
                Users is on Risk level info screen
                """
            }
        }
    }

    func testRedPath() throws {
        let postcode = "SW15"
        $runner.initialState.postcode = postcode
        $runner.initialState.localAuthorityId = "E09000025"

        $runner.report(scenario: "Area risk level", "Red risk (high)") {
            """
            Users see the home screen with red risk and navigate to risk level alert info
            """
        }
        try runner.run { app in
            let homeScreen = HomeScreen(app: app)

            app.checkOnHomeScreen(postcode: postcode, alertLevel: 3)

            runner.step("Home Screen") {
                """
                When the user is on the Home screen and can tap on risk level banner
                """
            }

            homeScreen.riskLevelBanner(for: postcode, title: "[postcode] is in Local Alert Level 3").tap()

            runner.step("Risk level info") {
                """
                Users is on Risk level info screen
                """
            }
        }
    }

    func testMaroonPath() throws {
        let postcode = "SW17"
        $runner.initialState.postcode = postcode
        $runner.initialState.localAuthorityId = "E09000032"

        $runner.report(scenario: "Area risk level", "Maroon risk (high)") {
            """
            Users see the home screen with maroon risk and navigate to risk level alert info
            """
        }
        try runner.run { app in
            let homeScreen = HomeScreen(app: app)

            app.checkOnHomeScreen(postcode: postcode, alertLevel: 3)

            runner.step("Home Screen") {
                """
                When the user is on the Home screen and can tap on risk level banner
                """
            }

            homeScreen.riskLevelBanner(for: postcode, title: "[postcode] is in Local Alert Level 3").tap()

            runner.step("Risk level info") {
                """
                Users is on Risk level info screen
                """
            }
        }
    }

    func testBlackPath() throws {
        let postcode = "SW20"
        $runner.initialState.postcode = postcode
        $runner.initialState.localAuthorityId = "E09000021"

        $runner.report(scenario: "Area risk level", "Black risk (very high)") {
            """
            Users see the home screen with black risk and navigate to risk level alert info
            """
        }
        try runner.run { app in
            let homeScreen = HomeScreen(app: app)

            app.checkOnHomeScreen(postcode: postcode, alertLevel: 3)

            runner.step("Home Screen") {
                """
                When the user is on the Home screen and can tap on risk level banner
                """
            }

            homeScreen.riskLevelBanner(for: postcode, title: "[postcode] is in Local Alert Level 3").tap()

            runner.step("Risk level info") {
                """
                Users is on Risk level info screen
                """
            }
        }
    }
}
