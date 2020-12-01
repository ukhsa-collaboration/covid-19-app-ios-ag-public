//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class SelectLocalAuthorityScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<SelectLocalAuthorityScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = SelectLocalAuthorityScreen(app: app)
            XCTAssertTrue(screen.title.exists)
            let description = screen.description(postcode: runner.scenario.postcode)
            XCTAssertTrue(description.exists)
            XCTAssert(screen.linkBtn.exists)
            XCTAssert(screen.localAuthorityCard(
                checked: false,
                title: SelectLocalAuthorityScreenScenario.localAuthorities[0].name
            ).exists)
            XCTAssert(screen.localAuthorityCard(
                checked: false,
                title: SelectLocalAuthorityScreenScenario.localAuthorities[1].name
            ).exists)
            XCTAssert(screen.localAuthorityCard(
                checked: false,
                title: SelectLocalAuthorityScreenScenario.localAuthorities[2].name
            ).exists)
            XCTAssertTrue(screen.button.exists)
        }
    }
    
    func testTapLinkBtn() throws {
        try runner.run { app in
            let screen = SelectLocalAuthorityScreen(app: app)
            
            screen.linkBtn.tap()
            XCTAssert(app.staticTexts[runner.scenario.linkAlertTitle].exists)
        }
    }
    
    func testLocalAuthoritySelection() throws {
        try runner.run { app in
            let screen = SelectLocalAuthorityScreen(app: app)
            screen.localAuthorityCard(checked: false, title: SelectLocalAuthorityScreenScenario.supportedLocalAuthority.name).tap()
            XCTAssert(screen.localAuthorityCard(checked: true, title: SelectLocalAuthorityScreenScenario.supportedLocalAuthority.name).exists)
        }
    }
    
    func testTapConfirmBtn() throws {
        try runner.run { app in
            let screen = SelectLocalAuthorityScreen(app: app)
            screen.localAuthorityCard(checked: false, title: SelectLocalAuthorityScreenScenario.supportedLocalAuthority.name).tap()
            screen.button.tap()
            XCTAssert(app.staticTexts[runner.scenario.confirmAlertTitle].exists)
        }
    }
    
    func testNoSelectionError() throws {
        try runner.run { app in
            let screen = SelectLocalAuthorityScreen(app: app)
            screen.button.tap()
            XCTAssert(screen.noSelectionError.exists)
        }
    }
    
    func testUnsupportedCountryError() throws {
        try runner.run { app in
            let screen = SelectLocalAuthorityScreen(app: app)
            screen.localAuthorityCard(checked: false, title: SelectLocalAuthorityScreenScenario.unsupportedLocalAuthority.name).tap()
            screen.button.tap()
            XCTAssert(screen.unsupportedCountryError.exists)
        }
    }
    
}
