//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Localization
import Scenarios
import XCTest

class SettingsFlowTests: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<SandboxedScenario>

    override func setUp() {
        $runner.initialState.exposureNotificationsAuthorized = true
        $runner.initialState.userNotificationsAuthorized = false
        $runner.initialState.postcode = "S1"
        $runner.initialState.localAuthorityId = "E08000019" // Sheffield
    }

    func testVenueHistoryWithoutRecords() throws {
        $runner.enable(\.$venueCheckInToggle)
        $runner.report(scenario: "Settings - Venue history", "No records") {
            """
            Users tap on the Settings button in the Home screen,
            Users tap on the Venue History entry,
            Users get to the Venue history screen, without records.
            """
        }
        try runner.run { app in
            let homeScreen = HomeScreen(app: app)
            XCTAssertTrue(homeScreen.settingsButton.exists)

            runner.step("Home screen") {
                """
                The user is presented the Home screen.
                The user taps on the settings button.
                """
            }

            app.scrollTo(element: homeScreen.settingsButton)
            homeScreen.settingsButton.tap()

            let settingsScreen = SettingsScreen(app: app)
            XCTAssertTrue(settingsScreen.venueHistoryRow.exists)

            runner.step("Settings screen") {
                """
                The user is presented the Settings screen.
                The user taps on the Venue History button.
                """
            }

            settingsScreen.venueHistoryRow.tap()

            let venueHistoryScreen = VenueHistoryScreen(app: app)
            XCTAssertTrue(venueHistoryScreen.noRecordsYetLabel.exists)

            runner.step("Venue History screen") {
                """
                The user is presented the Venue History screen.
                """
            }
        }
    }

    func testVenueHistoryWithRecords() throws {
        $runner.enable(\.$venueCheckInToggle)
        $runner.report(scenario: "Settings - Venue history", "With records") {
            """
            Users tap on the Settings button in the Home screen,
            Users tap on the Venue History entry,
            Users get to the Venue history screen to see their CheckIns.
            """
        }

        $runner.initialState.hasCheckIns = true

        try runner.run { app in
            let homeScreen = HomeScreen(app: app)
            XCTAssertTrue(homeScreen.settingsButton.exists)

            runner.step("Home screen") {
                """
                The user is presented the Home screen.
                The user taps on the settings button.
                """
            }

            app.scrollTo(element: homeScreen.settingsButton)
            homeScreen.settingsButton.tap()

            let settingsScreen = SettingsScreen(app: app)
            XCTAssertTrue(settingsScreen.venueHistoryRow.exists)

            runner.step("Settings screen") {
                """
                The user is presented the Settings screen.
                The user taps on the Venue History button.
                """
            }

            settingsScreen.venueHistoryRow.tap()

            let venueHistoryScreen = VenueHistoryScreen(app: app)
            XCTAssertTrue(venueHistoryScreen.checkInCell().exists)

            runner.step("Venue History screen") {
                """
                The user is presented the Venue History screen with the recorded CheckIns.
                """
            }
        }
    }

    func testLanguageSelection() throws {
        $runner.report(scenario: "Settings - Language selection", "Happy path") {
            """
            Users tap on the Settings button in the Home screen,
            Users tap on the Language entry,
            Users get to the Language selection screen to see the currently selected language, and could change their selection.
            """
        }

        try runner.run { app in
            let homeScreen = HomeScreen(app: app)
            XCTAssertTrue(homeScreen.settingsButton.exists)

            runner.step("Home screen") {
                """
                The user is presented the Home screen.
                The user taps on the settings button.
                """
            }

            app.scrollTo(element: homeScreen.settingsButton)
            homeScreen.settingsButton.tap()

            let settingsScreen = SettingsScreen(app: app)
            XCTAssertTrue(settingsScreen.languageRow.exists)

            runner.step("Settings screen") {
                """
                The user is presented the Settings screen.
                The user taps on the Language button.
                """
            }

            settingsScreen.languageRow.tap()

            let languageSelectionScreen = LanguageSelectionScreen(app: app)
            XCTAssertTrue(languageSelectionScreen.currentSelectedLanguageCell.isSelected)

            languageSelectionScreen.newSelectedLanguageCell.tap()

            runner.step("Language Selection screen") {
                """
                The user is presented the Language Selection screen with the currently selected language.
                The user could change the selected language.
                """
            }
        }
    }

    func testMyDataWithoutRecords() throws {
        $runner.report(scenario: "Settings - My Data", "No records") {
            """
            Users tap on the Settings button in the Home screen,
            Users tap on the My Data entry,
            Users get to the My Data screen without records.
            """
        }

        try runner.run { app in
            let homeScreen = HomeScreen(app: app)
            XCTAssertTrue(homeScreen.settingsButton.exists)

            runner.step("Home screen") {
                """
                The user is presented the Home screen.
                The user taps on the settings button.
                """
            }

            app.scrollTo(element: homeScreen.settingsButton)
            homeScreen.settingsButton.tap()

            let settingsScreen = SettingsScreen(app: app)
            XCTAssertTrue(settingsScreen.myDataRow.exists)

            runner.step("Settings screen") {
                """
                The user is presented the Settings screen.
                The user taps on the My Data button.
                """
            }

            settingsScreen.myDataRow.tap()

            let myDataScreen = MyDataScreen(app: app)
            XCTAssertTrue(myDataScreen.noRecordsYetLabel.exists)

            runner.step("My Data screen") {
                """
                The user is presented the My Data screen.
                """
            }
        }
    }

    func testMyDataWithRecords() throws {
        let exposureDay = GregorianDay.today.advanced(by: -Sandbox.Config.Isolation.daysSinceReceivingExposureNotification).startDate(in: .current)

        $runner.initialState.isolationCase = Sandbox.Text.IsolationCase.contact.rawValue

        $runner.report(scenario: "Settings - My Data", "With records") {
            """
            Users are already isolating as contact case,
            Users tap on the Settings button in the Home screen,
            Users tap on the My Data entry,
            Users get to the My Data screen to see their exposure notification data.
            """
        }

        try runner.run { app in

            let homeScreen = HomeScreen(app: app)
            XCTAssertTrue(homeScreen.settingsButton.exists)

            runner.step("Home screen") {
                """
                The user is presented the Home screen.
                The user taps on the settings button.
                """
            }

            app.scrollTo(element: homeScreen.settingsButton)
            homeScreen.settingsButton.tap()

            let settingsScreen = SettingsScreen(app: app)
            XCTAssertTrue(settingsScreen.myDataRow.exists)

            runner.step("Settings screen") {
                """
                The user is presented the Settings screen.
                The user taps on the My Data button.
                """
            }

            settingsScreen.myDataRow.tap()

            let myDataScreen = MyDataScreen(app: app)
            XCTAssertTrue(myDataScreen.exposureNotificationEncounterDateCell(date: exposureDay).exists)
            app.scrollTo(element: myDataScreen.exposureNotificationSectionHeader)
            XCTAssertTrue(myDataScreen.exposureNotificationSectionHeader.exists)

            runner.step("My Data screen") {
                """
                The user is presented the My Data screen.
                """
            }
        }
    }
}
