//
// Copyright © 2022 DHSC. All rights reserved.
//

import Common
import Localization
import Scenarios
import XCTest

class SelfReportingFlowTests: XCTestCase {
    @Propped
    private var runner: ApplicationRunner<SandboxedScenario>

    override func setUp() {
        $runner.enable(\.$selfReportingToggle)
        $runner.initialState.exposureNotificationsAuthorized = true
        $runner.initialState.userNotificationsAuthorized = true
        $runner.initialState.postcode = "SW12"
        $runner.initialState.localAuthorityId = "E09000022"
    }

    func testPositiveResultShareKeysNhsLfdTestResultsReported () throws {
        $runner.report(scenario: "Self Reporting", "Positive + share + NHS LFD + has already reported") {
            """
            User reports a positive NHS LFD test, share keys and has already reported the test results on GOV.UK.
            The user gets advice to try to stay at home.
            """
        }
        try runner.run { app in
            homeScreen(app: app)
            enterTestResultScreen(app: app)
            shareTestResultScreen(app: app)
            alertScreen(app: app, share: true)
            testKitTypeScreen(app: app, lfdTest: true)
            testSupplierScreen(app: app, nhsTest: true)
            testDateScreen(app: app)
            symptomsScreen(app: app)
            symptomsDateScreen(app: app)
            reportedResultScreen(app: app, selectedYes: true)
            checkAnswers(app: app)
            selfReportingAnswersSubmitted(app: app, sharedKeys: true, reportedResult: true)
            selfReportingAdvice(app: app, reportedResult: true, outOfIsolation: false)
        }
    }

    func testPositiveResultShareKeysNhsLfdTestNotResultsReported () throws {
        $runner.report(scenario: "Self Reporting", "Positive + share + NHS LFD + has not reported") {
            """
            User reports a positive NHS LFD test, share keys and has not reported the test results on GOV.UK.
            The user is told to report the positive test result on GOV.UK and gets advice to try to stay at home.
            """
        }
        try runner.run { app in
            homeScreen(app: app)
            enterTestResultScreen(app: app)
            shareTestResultScreen(app: app)
            alertScreen(app: app, share: true)
            testKitTypeScreen(app: app, lfdTest: true)
            testSupplierScreen(app: app, nhsTest: true)
            testDateScreen(app: app)
            symptomsScreen(app: app)
            symptomsDateScreen(app: app)
            reportedResultScreen(app: app, selectedYes: false)
            checkAnswers(app: app)
            selfReportingAnswersSubmitted(app: app, sharedKeys: true, reportedResult: false)
            selfReportingAdvice(app: app, reportedResult: false, outOfIsolation: false)
        }
    }

    func testPositiveResultShareKeysPrivateLfdTest () throws {
        $runner.report(scenario: "Self Reporting", "Positive + share + private LFD") {
            """
            User reports a positive private LFD test and share keys.
            The user gets advice to try to stay at home.
            """
        }
        try runner.run { app in
            homeScreen(app: app)
            enterTestResultScreen(app: app)
            shareTestResultScreen(app: app)
            alertScreen(app: app, share: true)
            testKitTypeScreen(app: app, lfdTest: true)
            testSupplierScreen(app: app, nhsTest: false)
            testDateScreen(app: app)
            symptomsScreen(app: app)
            symptomsDateScreen(app: app)
            checkAnswers(app: app)
            selfReportingAnswersSubmitted(app: app, sharedKeys: true)
            selfReportingAdvice(app: app, outOfIsolation: false)
        }
    }

    func testPositiveResultShareKeysPcrTest () throws {
        $runner.report(scenario: "Self Reporting", "Positive + share + PCR test") {
            """
            User reports a positive PCR test and share keys.
            The user gets advice to try to stay at home.
            """
        }
        try runner.run { app in
            homeScreen(app: app)
            enterTestResultScreen(app: app)
            shareTestResultScreen(app: app)
            alertScreen(app: app, share: true)
            testKitTypeScreen(app: app, lfdTest: false)
            testDateScreen(app: app)
            symptomsScreen(app: app)
            symptomsDateScreen(app: app)
            checkAnswers(app: app)
            selfReportingAnswersSubmitted(app: app, sharedKeys: true)
            selfReportingAdvice(app: app, outOfIsolation: false)
        }
    }

    func testPositiveResultDoNotShareKeysNhsLfdTestResultsReported () throws {
        $runner.report(scenario: "Self Reporting", "Positive + do not share + NHS LFD test + has already reported") {
            """
            User reports a positive NHS LFD test, do not share keys and has already reported the test results on GOV.UK.
            The user gets advice to try to stay at home.
            """
        }
        try runner.run { app in
            homeScreen(app: app)
            enterTestResultScreen(app: app)
            shareTestResultScreen(app: app)
            alertScreen(app: app, share: false)
            willNotNotifyOthersScreen(app: app)
            testKitTypeScreen(app: app, lfdTest: true)
            testSupplierScreen(app: app, nhsTest: true)
            testDateScreen(app: app)
            symptomsScreen(app: app)
            symptomsDateScreen(app: app)
            reportedResultScreen(app: app, selectedYes: true)
            checkAnswers(app: app)
            selfReportingAnswersSubmitted(app: app, sharedKeys: false, reportedResult: true)
            selfReportingAdvice(app: app, reportedResult: true, outOfIsolation: false)
        }
    }

    func testPositiveResultDoNotShareKeysNhsLfdTestNotResultsReported () throws {
        $runner.report(scenario: "Self Reporting", "Positive + do not share + NHS LFD test + has not reported") {
            """
            User reports a positive NHS LFD test, do not share keys and has not reported the test results on GOV.UK.
            The user is told to report the positive test result on GOV.UK and gets advice to try to stay at home.
            """
        }
        try runner.run { app in
            homeScreen(app: app)
            enterTestResultScreen(app: app)
            shareTestResultScreen(app: app)
            alertScreen(app: app, share: false)
            willNotNotifyOthersScreen(app: app)
            testKitTypeScreen(app: app, lfdTest: true)
            testSupplierScreen(app: app, nhsTest: true)
            testDateScreen(app: app)
            symptomsScreen(app: app)
            symptomsDateScreen(app: app)
            reportedResultScreen(app: app, selectedYes: false)
            checkAnswers(app: app)
            selfReportingAnswersSubmitted(app: app, sharedKeys: false, reportedResult: false)
            selfReportingAdvice(app: app, reportedResult: false, outOfIsolation: false)
        }
    }

    func testPositiveResultDoNotShareKeysPrivateLfdTest () throws {
        $runner.report(scenario: "Self Reporting", "Positive + do not share + Private LFD test") {
            """
            User reports a positive private LFD test and do not share keys.
            The user gets advice to try to stay at home.
            """
        }
        try runner.run { app in
            homeScreen(app: app)
            enterTestResultScreen(app: app)
            shareTestResultScreen(app: app)
            alertScreen(app: app, share: false)
            willNotNotifyOthersScreen(app: app)
            testKitTypeScreen(app: app, lfdTest: true)
            testSupplierScreen(app: app, nhsTest: false)
            testDateScreen(app: app)
            symptomsScreen(app: app)
            symptomsDateScreen(app: app)
            checkAnswers(app: app)
            selfReportingAnswersSubmitted(app: app, sharedKeys: false)
            selfReportingAdvice(app: app, outOfIsolation: false)
        }
    }

    func testPositiveResultDoNotShareKeysPcrTest () throws {
        $runner.report(scenario: "Self Reporting", "Positive + do not share + PCR test") {
            """
            User reports a positive PCR test and do not share keys.
            The user gets advice to try to stay at home.
            """
        }
        try runner.run { app in
            homeScreen(app: app)
            enterTestResultScreen(app: app)
            shareTestResultScreen(app: app)
            alertScreen(app: app, share: false)
            willNotNotifyOthersScreen(app: app)
            testKitTypeScreen(app: app, lfdTest: false)
            testDateScreen(app: app)
            symptomsScreen(app: app)
            symptomsDateScreen(app: app)
            checkAnswers(app: app)
            selfReportingAnswersSubmitted(app: app, sharedKeys: false)
            selfReportingAdvice(app: app, outOfIsolation: false)
        }
    }

    func testIsolatingPositiveResultShareKeysNhsLfdTestResultsReported () throws {
        $runner.initialState.isolationCase = Sandbox.Text.IsolationCase.index.rawValue
        $runner.report(scenario: "Self Reporting", "Isolating + Positive + share + NHS LFD + has already reported") {
            """
            User is already isolating, reports a positive NHS LFD test, share keys and has already reported the test results on GOV.UK.
            The user gets advice to try to stay at home.
            """
        }
        try runner.run { app in
            homeScreenIsolating(app: app)
            enterTestResultScreen(app: app)
            shareTestResultScreen(app: app)
            alertScreen(app: app, share: true)
            testKitTypeScreen(app: app, lfdTest: true)
            testSupplierScreen(app: app, nhsTest: true)
            testDateScreen(app: app)
            reportedResultScreen(app: app, selectedYes: true)
            checkAnswers(app: app)
            selfReportingAnswersSubmitted(app: app, sharedKeys: true, reportedResult: true)
            selfReportingAdvice(app: app, reportedResult: true, outOfIsolation: false)
        }
    }

    func testIsolatingPositiveResultShareKeysNhsLfdTestNotResultsReported () throws {
        $runner.initialState.isolationCase = Sandbox.Text.IsolationCase.index.rawValue
        $runner.report(scenario: "Self Reporting", "Isolating + Positive + share + NHS LFD + has not reported") {
            """
            User is already isolating, reports a positive NHS LFD test, share keys and has not reported the test results on GOV.UK.
            The user is told to report the positive test result on GOV.UK and gets advice to try to stay at home.
            """
        }
        try runner.run { app in
            homeScreenIsolating(app: app)
            enterTestResultScreen(app: app)
            shareTestResultScreen(app: app)
            alertScreen(app: app, share: true)
            testKitTypeScreen(app: app, lfdTest: true)
            testSupplierScreen(app: app, nhsTest: true)
            testDateScreen(app: app)
            reportedResultScreen(app: app, selectedYes: false)
            checkAnswers(app: app)
            selfReportingAnswersSubmitted(app: app, sharedKeys: true, reportedResult: false)
            selfReportingAdvice(app: app, reportedResult: false, outOfIsolation: false)
        }
    }

    func testIsolatingPositiveResultShareKeysPrivateLfdTest () throws {
        $runner.initialState.isolationCase = Sandbox.Text.IsolationCase.index.rawValue
        $runner.report(scenario: "Self Reporting", "Isolating + Positive + share + private LFD") {
            """
            User is already isolating, reports a positive private LFD test and share keys.
            The user gets advice to try to stay at home.
            """
        }
        try runner.run { app in
            homeScreenIsolating(app: app)
            enterTestResultScreen(app: app)
            shareTestResultScreen(app: app)
            alertScreen(app: app, share: true)
            testKitTypeScreen(app: app, lfdTest: true)
            testSupplierScreen(app: app, nhsTest: false)
            testDateScreen(app: app)
            checkAnswers(app: app)
            selfReportingAnswersSubmitted(app: app, sharedKeys: true)
            selfReportingAdvice(app: app, outOfIsolation: false)
        }
    }

    func testIsolatingPositiveResultShareKeysPcrTest () throws {
        $runner.initialState.isolationCase = Sandbox.Text.IsolationCase.index.rawValue
        $runner.report(scenario: "Self Reporting", "Isolating + Positive + share + PCR test") {
            """
            User is already isolating, reports a positive PCR test and share keys.
            The user gets advice to try to stay at home.
            """
        }
        try runner.run { app in
            homeScreenIsolating(app: app)
            enterTestResultScreen(app: app)
            shareTestResultScreen(app: app)
            alertScreen(app: app, share: true)
            testKitTypeScreen(app: app, lfdTest: false)
            testDateScreen(app: app)
            checkAnswers(app: app)
            selfReportingAnswersSubmitted(app: app, sharedKeys: true)
            selfReportingAdvice(app: app, outOfIsolation: false)
        }
    }

    func testIsolatingPositiveResultDoNotShareKeysNhsLfdTestResultsReported () throws {
        $runner.initialState.isolationCase = Sandbox.Text.IsolationCase.index.rawValue
        $runner.report(scenario: "Self Reporting", "Isolating + Positive + do not share + NHS LFD test + has already reported") {
            """
            User is already isolating, reports a positive NHS LFD test, do not share keys and has already reported the test results on GOV.UK.
            The user gets advice to try to stay at home.
            """
        }
        try runner.run { app in
            homeScreenIsolating(app: app)
            enterTestResultScreen(app: app)
            shareTestResultScreen(app: app)
            alertScreen(app: app, share: false)
            willNotNotifyOthersScreen(app: app)
            testKitTypeScreen(app: app, lfdTest: true)
            testSupplierScreen(app: app, nhsTest: true)
            testDateScreen(app: app)
            reportedResultScreen(app: app, selectedYes: true)
            checkAnswers(app: app)
            selfReportingAnswersSubmitted(app: app, sharedKeys: false, reportedResult: true)
            selfReportingAdvice(app: app, reportedResult: true, outOfIsolation: false)
        }
    }

    func testIsolatingPositiveResultDoNotShareKeysNhsLfdTestNotResultsReported () throws {
        $runner.initialState.isolationCase = Sandbox.Text.IsolationCase.index.rawValue
        $runner.report(scenario: "Self Reporting", "Isolating + Positive + do not share + NHS LFD test + has not reported") {
            """
            User is already isolating, reports a positive NHS LFD test, do not share keys and has not reported the test results on GOV.UK.
            The user is told to report the positive test result on GOV.UK and gets advice to try to stay at home.
            """
        }
        try runner.run { app in
            homeScreenIsolating(app: app)
            enterTestResultScreen(app: app)
            shareTestResultScreen(app: app)
            alertScreen(app: app, share: false)
            willNotNotifyOthersScreen(app: app)
            testKitTypeScreen(app: app, lfdTest: true)
            testSupplierScreen(app: app, nhsTest: true)
            testDateScreen(app: app)
            reportedResultScreen(app: app, selectedYes: false)
            checkAnswers(app: app)
            selfReportingAnswersSubmitted(app: app, sharedKeys: false, reportedResult: false)
            selfReportingAdvice(app: app, reportedResult: false, outOfIsolation: false)
        }
    }

    func testIsolatingPositiveResultDoNotShareKeysPrivateLfdTest () throws {
        $runner.initialState.isolationCase = Sandbox.Text.IsolationCase.index.rawValue
        $runner.report(scenario: "Self Reporting", "Isolating + Positive + do not share + Private LFD test") {
            """
            User is already isolating, reports a positive private LFD test and do not share keys.
            The user gets advice to try to stay at home.
            """
        }
        try runner.run { app in
            homeScreenIsolating(app: app)
            enterTestResultScreen(app: app)
            shareTestResultScreen(app: app)
            alertScreen(app: app, share: false)
            willNotNotifyOthersScreen(app: app)
            testKitTypeScreen(app: app, lfdTest: true)
            testSupplierScreen(app: app, nhsTest: false)
            testDateScreen(app: app)
            checkAnswers(app: app)
            selfReportingAnswersSubmitted(app: app, sharedKeys: false)
            selfReportingAdvice(app: app, outOfIsolation: false)
        }
    }

    func testIsolatingPositiveResultDoNotShareKeysPcrTest () throws {
        $runner.initialState.isolationCase = Sandbox.Text.IsolationCase.index.rawValue
        $runner.report(scenario: "Self Reporting", "Isolating + Positive + do not share + PCR test") {
            """
            User is already isolating, reports a positive PCR test and do not share keys.
            The user gets advice to try to stay at home.
            """
        }
        try runner.run { app in
            homeScreenIsolating(app: app)
            enterTestResultScreen(app: app)
            shareTestResultScreen(app: app)
            alertScreen(app: app, share: false)
            willNotNotifyOthersScreen(app: app)
            testKitTypeScreen(app: app, lfdTest: false)
            testDateScreen(app: app)
            checkAnswers(app: app)
            selfReportingAnswersSubmitted(app: app, sharedKeys: false)
            selfReportingAdvice(app: app, outOfIsolation: false)
        }
    }

    func testNegativeTestResultTest () throws {
        $runner.report(scenario: "Self Reporting", "Negative test result") {
            """
            User chooses to report a negative test result.
            The user is presented with information that negative or void test results are not supported in the app.
            """
        }
        try runner.run { app in
            homeScreen(app: app)
            enterNegativeTestResultScreen(app: app)
            negativeOrVoidTestResultScreen(app: app)
        }
    }

    func testVoidTestResultTest () throws {
        $runner.report(scenario: "Self Reporting", "Void test result") {
            """
            User chooses to report a void test result.
            The user is presented with information that negative or void test results are not supported in the app.
            """
        }
        try runner.run { app in
            homeScreen(app: app)
            enterVoidTestResultScreen(app: app)
            negativeOrVoidTestResultScreen(app: app)
        }
    }
}

extension SelfReportingFlowTests {

    private func homeScreen(app: XCUIApplication) {
        let homeScreen = HomeScreen(app: app)

        app.checkOnHomeScreenNotIsolating()

        homeScreen.enterTestResultButton.tap()

        runner.step("Home Screen") {
            """
            When the user is on the Home screen they can tap 'Enter test result'
            """
        }
    }

    private func homeScreenIsolating(app: XCUIApplication) {
        let homeScreen = HomeScreen(app: app)

        homeScreen.enterTestResultButton.tap()

        runner.step("Home Screen") {
            """
            When the user is on the Home screen they can tap 'Enter test result'
            """
        }
    }

    private func enterTestResultScreen(app: XCUIApplication) {
        let enterTestResultScreen = SelfReportingTestTypeScreen(app: app)

        XCTAssertTrue(enterTestResultScreen.header.exists)

        enterTestResultScreen.positiveRadioButton(selected: false).tap()

        enterTestResultScreen.continueButton.tap()

        runner.step("Enter test result") {
            """
            The user is presented with these test result options: Positive, negative or void.
            The user taps on the positive radio button, then taps on continue.
            """
        }
    }

    private func enterNegativeTestResultScreen(app: XCUIApplication) {
        let enterTestResultScreen = SelfReportingTestTypeScreen(app: app)

        XCTAssertTrue(enterTestResultScreen.header.exists)

        enterTestResultScreen.negativeRadioButton(selected: false).tap()

        enterTestResultScreen.continueButton.tap()

        runner.step("Enter test result") {
            """
            The user is presented with these test result options: Positive, negative or void.
            The user taps on the negative radio button, then taps on continue.
            """
        }
    }

    private func enterVoidTestResultScreen(app: XCUIApplication) {
        let enterTestResultScreen = SelfReportingTestTypeScreen(app: app)

        XCTAssertTrue(enterTestResultScreen.header.exists)

        enterTestResultScreen.voidRadioButton(selected: false).tap()

        enterTestResultScreen.continueButton.tap()

        runner.step("Enter test result") {
            """
            The user is presented with these test result options: Positive, negative or void.
            The user taps on the void radio button, then taps on continue.
            """
        }
    }

    private func negativeOrVoidTestResultScreen(app: XCUIApplication) {
        let negativeOrVoidTestResultScreen = SelfReportingNegativeOrVoidTestResultScreen(app: app)

        XCTAssertTrue(negativeOrVoidTestResultScreen.header.exists)

        app.scrollTo(element: negativeOrVoidTestResultScreen.primaryButton)
        negativeOrVoidTestResultScreen.primaryButton.tap()

        runner.step("Negative or void test result") {
            """
            The user is presented with information that negative or void test results are not possible to share in the app.
            The user taps on Back to home screen.
            """
        }
    }

    private func shareTestResultScreen(app: XCUIApplication) {
        let shareTestResultScreen = SelfReportingShareTestResultScreen(app: app)

        XCTAssertTrue(shareTestResultScreen.header.exists)

        shareTestResultScreen.continueButton.tap()

        runner.step("Share positive test result") {
            """
            The user is presented with information about sharing there positive test result.
            The user taps on continue.
            """
        }
    }

    private func willNotNotifyOthersScreen(app: XCUIApplication) {
        let willNotNotifyOthersScreen = SelfReportingWillNotNotifyOthersScreen(app: app)

        XCTAssertTrue(willNotNotifyOthersScreen.header.exists)

        willNotNotifyOthersScreen.continueButton.tap()

        runner.step("App will not notify others") {
            """
            The user is presented with information that app will not notify other since key sharing was declined by user.
            The user taps on continue.
            """
        }
    }

    private func alertScreen(app: XCUIApplication, share: Bool) {
        let alertScreen = SimulatedShareRandomIdsScreen(app: app)

        if share {
            alertScreen.shareButton.tap()
        } else {
            alertScreen.dontShareButton.tap()
        }

        runner.step("Share random ids - System Alert") {
            """
            The user is asked by the system to confirm sharing the device random ids.
            The user taps on \(share ? "Share" : "Don't share").
            """
        }
    }

    private func testKitTypeScreen(app: XCUIApplication, lfdTest: Bool) {
        let testKitTypeScreen = SelfReportingTestKitTypeScreen(app: app)

        XCTAssertTrue(testKitTypeScreen.header.exists)

        if lfdTest {
            testKitTypeScreen.lfdRadioButton(selected: false).tap()
        } else {
            testKitTypeScreen.pcrRadioButton(selected: false).tap()
        }
        testKitTypeScreen.continueButton.tap()

        runner.step("Test kit type") {
            """
            The user is presented with two test kit types: Rapid lateral flow test and PCR test
            The user taps on the \(lfdTest ? "'Rapid lateral flow test'" : "'PCR test'") radio button, then taps on continue.
            """
        }
    }

    private func testSupplierScreen(app: XCUIApplication, nhsTest: Bool) {
        let testSupplierScreen = SelfReportingTestSupplierScreen(app: app)

        XCTAssertTrue(testSupplierScreen.header.exists)

        if nhsTest {
            testSupplierScreen.yesRadioButton(selected: false).tap()
        } else {
            testSupplierScreen.noRadioButton(selected: false).tap()
        }
        testSupplierScreen.continueButton.tap()

        runner.step("How you got your test") {
            """
            The user is presented with a question asking if the the test was from NHS.
            The user selects \(nhsTest ? "yes" : "no") and taps continue.
            """
        }
    }

    private func testDateScreen(app: XCUIApplication) {
        let testDateScreen = SelfReportingTestDateScreen(app: app)

        XCTAssertTrue(testDateScreen.header.exists)

        testDateScreen.doNotRememberNotChecked.tap()
        testDateScreen.continueButton.tap()

        runner.step("Test date") {
            """
            The user is asked to enter the test day.
            The user selects 'I do not remember the date' and taps continue.
            """
        }
    }

    private func symptomsScreen(app: XCUIApplication) {
        let symptomsScreen = SelfReportingSymptomsScreen(app: app)

        XCTAssertTrue(symptomsScreen.header.exists)

        symptomsScreen.yesRadioButton(selected: false).tap()
        symptomsScreen.continueButton.tap()

        runner.step("Symptoms") {
            """
            The user is presented with a list of symptoms.
            The user selects yes to haveing any of the symptoms listen, before the test was taken.
            The user taps continue.
            """
        }
    }

    private func symptomsDateScreen(app: XCUIApplication) {
        let symptomsDateScreen = SelfReportingSymptomsDateScreen(app: app)

        XCTAssertTrue(symptomsDateScreen.header.exists)

        symptomsDateScreen.doNotRememberNotChecked.tap()
        symptomsDateScreen.continueButton.tap()

        runner.step("Symptoms start date") {
            """
            The user is asked to enter the symptoms start date.
            The user selects 'I do not remember the date' and taps continue.
            """
        }
    }

    private func reportedResultScreen(app: XCUIApplication, selectedYes: Bool) {
        let reportedResultScreen = SelfReportingResultReportedScreen(app: app)

        XCTAssertTrue(reportedResultScreen.header.exists)

        if selectedYes {
            reportedResultScreen.yesRadioButton(selected: false).tap()
        } else {
            reportedResultScreen.noRadioButton(selected: false).tap()
        }
        reportedResultScreen.continueButton.tap()

        runner.step("Whether you've reported your result") {
            """
            The user is asked whether they've reported their result on GOV.UK
            The user selects \(selectedYes ? "yes" : "no") and taps continue.
            """
        }
    }

    private func checkAnswers(app: XCUIApplication) {
        let checkAnswers = SelfReportingCheckAnswersScreen(app: app)

        XCTAssertTrue(checkAnswers.header.exists)

        checkAnswers.continueButton.tap()

        runner.step("Check your answers") {
            """
            The user is presented with a summary of the answers for review.
            The user taps 'Submit and continue'.
            """
        }
    }

    private func selfReportingAnswersSubmitted(app: XCUIApplication, sharedKeys: Bool, reportedResult: Bool = true) {
        switch (sharedKeys, reportedResult) {
        case (true, true):
            let screen = AnswersSubmittedSharedKeysReportedResultScreen(app: app)
            XCTAssertTrue(screen.header.waitForExistence(timeout: 0.3))
            XCTAssertTrue(screen.description.waitForExistence(timeout: 0.3))
            screen.continueButton.tap()
        case (true, false):
            let screen = AnswersSubmittedSharedKeysNotReportedResultScreen(app: app)
            XCTAssertTrue(screen.header.waitForExistence(timeout: 0.3))
            XCTAssertTrue(screen.description.waitForExistence(timeout: 0.3))
            screen.continueButton.tap()
        case (false, true):
            let screen = AnswersSubmittedNotSharedKeysReportedResultScreen(app: app)
            XCTAssertTrue(screen.header.waitForExistence(timeout: 0.3))
            XCTAssertTrue(screen.description.waitForExistence(timeout: 0.3))
            screen.continueButton.tap()
        case (false, false):
            let screen = AnswersSubmittedNotSharedKeysNotReportedResultScreen(app: app)
            XCTAssertTrue(screen.header.waitForExistence(timeout: 0.3))
            XCTAssertTrue(screen.description.waitForExistence(timeout: 0.3))
            screen.continueButton.tap()
        }

        runner.step("Answers submitted") {
            """
            The user is presented with a thank you screen.
            The user taps 'Continue'.
            """
        }
    }

    private func selfReportingAdvice(app: XCUIApplication, reportedResult: Bool = true, outOfIsolation: Bool) {
        switch (reportedResult, outOfIsolation) {
        case (true, false):
            let screen = AdviceReportedResultsScreen(app: app)
            XCTAssertTrue(screen.primaryButton.exists)
            screen.primaryButton.tap()
        case (false, false):
            let screen = AdviceNotReportedResultsScreen(app: app)
            XCTAssertTrue(screen.secondaryLinkButton.exists)
            screen.secondaryLinkButton.tap()
        case (true, true):
            let screen = AdviceReportedResultsOutOfIsolationScreen(app: app)
            XCTAssertTrue(screen.primaryButton.exists)
            screen.primaryButton.tap()
        case (false, true):
            let screen = AdviceNotReportedResultsOutOfIsolationScreen(app: app)
            XCTAssertTrue(screen.secondaryLinkButton.exists)
            screen.secondaryLinkButton.tap()
        }

        runner.step("Your advice") {
            """
            The user is presented with advice.
            The user taps 'Back to home'.
            """
        }
    }
}
