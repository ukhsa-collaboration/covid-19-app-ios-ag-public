//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class AboutThisAppScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<AboutThisAppScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = AboutThisAppScreen(app: app)
            
            XCTAssert(screen.aboutThisAppHeadingLabel.exists)
            XCTAssert(screen.aboutThisAppParagraphOne.exists)
            XCTAssert(screen.aboutThisAppParagraphTwo.exists)
            XCTAssert(screen.aboutThisAppParagraphThree.exists)
            XCTAssert(screen.aboutThisAppInstructonForUse.exists)
            XCTAssert(screen.aboutThisAppButton.exists)
            
            XCTAssert(screen.commonQuestionsHeading.exists)
            XCTAssert(screen.commonQuestionsDescription.exists)
            XCTAssert(screen.commonQuestionsButton.exists)
            
            XCTAssert(screen.ourPoliciesHeading.exists)
            XCTAssert(screen.ourPoliciesDescription.exists)
            XCTAssert(screen.termsOfUseButton.exists)
            XCTAssert(screen.privacyNoticeButton.exists)
            XCTAssert(screen.accessibilityStatementButton.exists)
            
            XCTAssert(screen.showMyDataHeading.exists)
            XCTAssert(screen.showMyDataDescription.exists)
            XCTAssert(screen.seeDataDescription.exists)
            
            XCTAssert(screen.softwareInformationHeading.exists)
            XCTAssert(screen.appName.exists)
            XCTAssert(screen.version.exists)
            XCTAssert(screen.dateOfRelease.exists)
            XCTAssert(screen.manufacturer.exists)
            
            XCTAssert(screen.feedbackInformationTitle.exists)
            XCTAssert(screen.feedbackInformationDescription.exists)
            XCTAssert(screen.feedbackInformationButton.exists)
        }
    }
    
    func testCommonQuestionsLinkAction() throws {
        try runner.run { app in
            let screen = AboutThisAppScreen(app: app)
            screen.commonQuestionsButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.commonQuestionsTapped].exists)
        }
    }
    
    func testTermsOfUseLinkAction() throws {
        try runner.run { app in
            let screen = AboutThisAppScreen(app: app)
            screen.termsOfUseButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.termsOfUseTapped].exists)
        }
    }
    
    func testPrivacyNoticeLinkAction() throws {
        try runner.run { app in
            let screen = AboutThisAppScreen(app: app)
            screen.privacyNoticeButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.privacyNoticeTapped].exists)
        }
    }
    
    func testAccessibilityStatementinkAction() throws {
        try runner.run { app in
            let screen = AboutThisAppScreen(app: app)
            screen.accessibilityStatementButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.accessibilityStatementTapped].exists)
        }
    }
        
    func testProvideFeedbackLinkAction() throws {
        try runner.run { app in
            let screen = AboutThisAppScreen(app: app)
            screen.feedbackInformationButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.provideFeedbackTapped].exists)
        }
    }
    
}
