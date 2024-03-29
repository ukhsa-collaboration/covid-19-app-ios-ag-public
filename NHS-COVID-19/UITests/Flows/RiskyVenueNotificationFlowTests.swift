//
// Copyright © 2022 DHSC. All rights reserved.
//

import Common
import Foundation
import XCTest

class RiskyVenueNotificationFlowTests: XCTestCase {

    @Propped
    private var runner: ApplicationRunner<SandboxedScenario>

    override func setUpWithError() throws {
        $runner.initialState.exposureNotificationsAuthorized = true
        $runner.initialState.userNotificationsAuthorized = false
        $runner.initialState.postcode = "S1"
        $runner.initialState.localAuthorityId = "Sheffield"
    }

    func testShowWarnAndInformRiskyVenueNotification() throws {
        $runner.initialState.riskyVenueMessageType = Sandbox.Text.RiskyVenueMessageType.warnAndInform.rawValue

        $runner.report(scenario: "Risky venue notification", "Warn and inform") {
            """
            User receives a warn and inform risky venue notification,
            User acknowledges the notification and goes back to home screen.
            """
        }

        try runner.run { app in

            let riskyVenueInformationScreen = RiskyVenueInformationScreen(app: app, venueName: "Venue 1", checkInDate: DateProvider().currentDate)
            XCTAssertTrue(riskyVenueInformationScreen.actionButton.exists)

            runner.step("Risky Venue Notification screen") {
                """
                The user is presented the warn and inform risky venue notification screen.
                The user taps on Back To Home button.
                """
            }

            riskyVenueInformationScreen.actionButton.tap()

            runner.step("Home screen") {
                """
                The user is presented the Home screen again.
                """
            }
        }
    }

    func testShowWarnAndBookATestRiskyVenueNotification() throws {
        $runner.initialState.isolationCase = Sandbox.Text.IsolationCase.index.rawValue
        $runner.initialState.riskyVenueMessageType = Sandbox.Text.RiskyVenueMessageType.warnAndBookATest.rawValue

        $runner.report(scenario: "Risky venue notification", "Warn and book a test") {
            """
            User receives a warn and book a test risky venue notification,
            User taps on book a test for yourself button,
            User goes through the book a test flow, and comes back to home screen.
            """
        }

        try runner.run { app in

            let riskyVenueInformationBookATestScreen = RiskyVenueInformationBookATestScreen(app: app)
            XCTAssertTrue(riskyVenueInformationBookATestScreen.bookATestButton.exists)

            runner.step("Risky Venue Notification screen") {
                """
                The user is presented the warn and book a test risky venue notification.
                The user taps on book a free test button.
                """
            }

            riskyVenueInformationBookATestScreen.bookATestButton.tap()

            let bookATestScreen = BookATestScreen(app: app)
            XCTAssertTrue(bookATestScreen.button.exists)

            runner.step("Book a Free Test screen") {
                """
                The user is presented the Book a free test screen.
                The user taps on book a test for yourself button
                The user gets redirected to a web browser to book a test
                """
            }

            bookATestScreen.button.tap()

            runner.step("Home screen") {
                """
                The user goes back to home screen
                """
            }
        }
    }

    func testShowWarnAndCheckSymptomsAndBookATestRiskyVenueNotificationWales() throws {
        $runner.initialState.riskyVenueMessageType = Sandbox.Text.RiskyVenueMessageType.warnAndBookATest.rawValue
        $runner.initialState.postcode = "LL44"
        $runner.initialState.localAuthorityId = "W06000002"
        $runner.report(scenario: "Risky venue notification Wales", "Warn and enter symptoms and book a test") {
            """
            User receives a warn and book a test risky venue notification,
            User taps on has symptoms,
            User selects symptoms and is notified of corona symptoms,
            User taps on book a test for yourself button,
            User goes through the book a test flow, and comes back to home screen.
            """
        }

        try runner.run { app in

            let riskyVenueInformationBookATestScreen = RiskyVenueInformationBookATestScreen(app: app)
            XCTAssertTrue(riskyVenueInformationBookATestScreen.bookATestButton.exists)

            runner.step("Risky Venue Notification screen") {
                """
                The user is presented the warn and book a test risky venue notification.
                The user taps on book a free test button.
                """
            }

            riskyVenueInformationBookATestScreen.bookATestButton.tap()

            let warnAndTestCheckSymptomsScreen = WarnAndTestCheckSymptomsScreen(app: app)
            XCTAssertTrue(warnAndTestCheckSymptomsScreen.submitButton.exists)

            runner.step("Do you have symptoms? screen") {
                """
                The user is presented the Do you have symptoms? screen.
                The user taps on no button.
                The user gets redirected to order a free test screen.
                """
            }

            warnAndTestCheckSymptomsScreen.submitButton.tap()

            runner.step("Symptom List") {
                """
                The user is presented a list of symptoms
                """
            }

            let symptomsListScreen = SymptomsListScreen(app: app)

            symptomsListScreen.symptomCard(
                value: localize(.symptom_card_unchecked, applyCurrentLanguageDirection: false),
                heading: Sandbox.Text.SymptomsList.cardHeading.rawValue.apply(direction: currentLanguageDirection()),
                content: Sandbox.Text.SymptomsList.cardContent.rawValue.apply(direction: currentLanguageDirection())
            ).tap()

            runner.step("Symptom selected") {
                """
                The user selects a symptom and confirms the screen
                """
            }

            symptomsListScreen.reportButton.tap()

            let reviewSymptomsScreen = SymptomsReviewScreen(app: app)
            XCTAssert(reviewSymptomsScreen.heading.exists)

            runner.step("Review Symptoms") {
                """
                The user is presented a list of the selected symptoms for review
                """
            }

            reviewSymptomsScreen.confirmButton.tap()

            let positiveSymptomsScreen = PositiveSymptomsNoIsolationScreen(app: app)
            XCTAssert(positiveSymptomsScreen.heading.exists)

            runner.step("Try to stay at home screen") {
                """
                The user is asked to try to stay at home
                """
            }
            positiveSymptomsScreen.backToHomeButton.firstMatch.tap()

            runner.step("Home screen") {
                """
                The user is returned to the homescreen.
                """
            }

            app.checkOnHomeScreenNotIsolating()
        }
    }

    func testShowWarnAndCheckSymptomsAndBookATestRiskyVenueNotificationEngland() throws {
        $runner.initialState.riskyVenueMessageType = Sandbox.Text.RiskyVenueMessageType.warnAndBookATest.rawValue

        $runner.report(scenario: "Risky venue notification England", "Warn and enter symptoms and book a test") {
            """
            User in England receives a warn and book a test risky venue notification,
            User taps on has symptoms,
            User selects symptoms and is notified of corona symptoms,
            User is presented with the isolation advice,
            User continues to the latest guidance screen and comes back to home screen.
            """
        }

        try runner.run { app in

            let riskyVenueInformationBookATestScreen = RiskyVenueInformationBookATestScreen(app: app)
            XCTAssertTrue(riskyVenueInformationBookATestScreen.bookATestButton.exists)

            runner.step("Risky Venue Notification screen") {
                """
                The user is presented the warn and book a test risky venue notification.
                The user taps on book a free test button.
                """
            }

            riskyVenueInformationBookATestScreen.bookATestButton.tap()

            let warnAndTestCheckSymptomsScreen = WarnAndTestCheckSymptomsScreen(app: app)
            XCTAssertTrue(warnAndTestCheckSymptomsScreen.submitButton.exists)

            runner.step("Do you have symptoms? screen") {
                """
                The user is presented the Do you have symptoms? screen.
                The user taps on no button.
                The user gets redirected to order a free test screen.
                """
            }

            warnAndTestCheckSymptomsScreen.submitButton.tap()

            runner.step("Symptom List") {
                """
                The user is presented a list of symptoms
                """
            }

            let symptomsListScreen = SymptomsListScreen(app: app)

            symptomsListScreen.symptomCard(
                value: localize(.symptom_card_unchecked, applyCurrentLanguageDirection: false),
                heading: Sandbox.Text.SymptomsList.cardHeading.rawValue.apply(direction: currentLanguageDirection()),
                content: Sandbox.Text.SymptomsList.cardContent.rawValue.apply(direction: currentLanguageDirection())
            ).tap()

            runner.step("Symptom selected") {
                """
                The user selects a symptom and confirms the screen
                """
            }

            symptomsListScreen.reportButton.tap()

            let reviewSymptomsScreen = SymptomsReviewScreen(app: app)
            XCTAssert(reviewSymptomsScreen.heading.exists)

            runner.step("Review Symptoms") {
                """
                The user is presented a list of the selected symptoms for review
                """
            }

            reviewSymptomsScreen.noDate.tap()

            runner.step("No Date") {
                """
                The can specify an onset date or tick that they don't remember the onset date, before confirming
                """
            }

            reviewSymptomsScreen.confirmButton.tap()

            let isolationAdviceForSymptomaticCasesEnglandScreen = IsolationAdviceForSymptomaticCasesEnglandScreen(app: app)
            XCTAssert(isolationAdviceForSymptomaticCasesEnglandScreen.heading.exists)

            runner.step("Isolation Advice screen for symptomatic cases England") {
                """
                The user in England is adviced to isolate, and given the option to continue to the guidance screen
                """
            }
            isolationAdviceForSymptomaticCasesEnglandScreen.continueButton.tap()

            let guidanceForSymptomaticCasesEnglandScreen = GuidanceForSymptomaticCasesEnglandScreen(app: app)
            XCTAssert(guidanceForSymptomaticCasesEnglandScreen.heading.exists)

            runner.step("Guidance screen for symptomatic cases England") {
                """
                The user in England is presented the latest COVID-19 guidance screen with an option to go back to home screen
                """
            }
            app.scrollTo(element: guidanceForSymptomaticCasesEnglandScreen.backToHomeButton)
            guidanceForSymptomaticCasesEnglandScreen.backToHomeButton.tap()

            runner.step("Home screen") {
                """
                The user is returned to the homescreen, which presents risk level indicator and different menu options.
                """
            }

            let date = GregorianDay.today.advanced(by: Sandbox.Config.Isolation.indexCaseSinceSelfDiagnosisUnknownOnset).startDate(in: .current)
            app.checkOnHomeScreenIsolatingInformational(date: date, days: Sandbox.Config.Isolation.indexCaseSinceSelfDiagnosisUnknownOnset)
        }
    }

    func testShowWarnAndCheckSymptomsAndBookALFDTestRiskyVenueNotification() throws {
        $runner.initialState.riskyVenueMessageType = Sandbox.Text.RiskyVenueMessageType.warnAndBookATest.rawValue

        $runner.report(scenario: "Risky venue notification", "Warn and book a LFD test") {
            """
            User receives a warn and book a test risky venue notification,
            User taps on no symptoms,
            User taps on order a new lfd test button,
            User goes through the book a test flow, and comes back to home screen.
            """
        }

        try runner.run { app in

            let riskyVenueInformationBookATestScreen = RiskyVenueInformationBookATestScreen(app: app)
            XCTAssertTrue(riskyVenueInformationBookATestScreen.bookATestButton.exists)

            runner.step("Risky Venue Notification screen") {
                """
                The user is presented the warn and book a test risky venue notification.
                The user taps on book a free test button.
                """
            }

            riskyVenueInformationBookATestScreen.bookATestButton.tap()

            let warnAndTestCheckSymptomsScreen = WarnAndTestCheckSymptomsScreen(app: app)
            XCTAssertTrue(warnAndTestCheckSymptomsScreen.submitButton.exists)

            runner.step("Do you have symptoms? screen") {
                """
                The user is presented the Do you have symptoms? screen.
                The user taps on no button.
                The user gets redirected to order a free test screen.
                """
            }

            warnAndTestCheckSymptomsScreen.cancelButton.tap()

            let orderFreeTestScreen = BookARapidTestScreen(app: app)
            XCTAssertTrue(orderFreeTestScreen.submitButton.exists)

            runner.step("Order a free test screen") {
                """
                The user is presented the Order LFD screen.
                The user taps on order a new lfd test link.
                The user gets redirected to a web browser to order a new lfd test.
                """
            }

            orderFreeTestScreen.submitButton.tap()

            runner.step("Home screen") {
                """
                The user goes back to home screen
                """
            }
        }
    }
}
