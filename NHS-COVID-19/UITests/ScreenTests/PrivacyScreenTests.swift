//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class PrivacyScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<PrivacyScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = PrivacyScreen(app: app)
            
            XCTAssertTrue(screen.title.exists)
            XCTAssertTrue(screen.privacyDespcription.exists)
            XCTAssertTrue(screen.dataDespcription1.exists)
            XCTAssertTrue(screen.dataDespcription2.exists)
            XCTAssertTrue(screen.privacyNotice.exists)
            XCTAssertTrue(screen.termsOfUse.exists)
            XCTAssertTrue(screen.linksHeader.exists)
            XCTAssertTrue(screen.agreeButton.exists)
            XCTAssertTrue(screen.noThanksButton.exists)
            XCTAssertTrue(screen.privacyHeader.exists)
            XCTAssertTrue(screen.dataHeader.exists)
        }
    }
    
    func testTappingPrivacyNotice() throws {
        try runner.run { app in
            let screen = PrivacyScreen(app: app)
            screen.privacyNotice.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.privacyNoticeTapped].exists)
        }
    }
    
    func testTapppingTermsOfUse() throws {
        try runner.run { app in
            let screen = PrivacyScreen(app: app)
            screen.termsOfUse.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.termsOfUseTapped].exists)
        }
    }
    
    func testTappingAgreeButton() throws {
        try runner.run { app in
            let screen = PrivacyScreen(app: app)
            screen.agreeButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.agreeButtonTapped].exists)
        }
    }
    
    func testTappingNoThanksButton() throws {
        try runner.run { app in
            let screen = PrivacyScreen(app: app)
            screen.noThanksButton.tap()
            XCTAssertTrue(app.staticTexts[runner.scenario.noThanksButtonTapped].exists)
        }
    }
    
}
