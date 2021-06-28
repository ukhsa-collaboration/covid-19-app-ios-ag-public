//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class SettingsScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<SettingsScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = SettingsScreen(app: app)
            XCTAssertTrue(screen.title.exists)
            XCTAssertTrue(screen.languageRow.exists)
            XCTAssertEqual(screen.languageRow.stringValue, runner.scenario.language.applyCurrentLanguageDirection())
            XCTAssertTrue(screen.deleteDataButton.exists)
            XCTAssertTrue(screen.myAreaRow.exists)
            XCTAssertTrue(screen.myDataRow.exists)
            XCTAssertTrue(screen.venueHistoryRow.exists)
        }
    }
    
    func testTappingMyArea() throws {
        try runner.run { app in
            let screen = SettingsScreen(app: app)
            
            screen.myAreaRow.tap()
            XCTAssertTrue(app.staticTexts[verbatim: runner.scenario.didTapMyArea].exists)
        }
    }
    
    func testTappingMyData() throws {
        try runner.run { app in
            let screen = SettingsScreen(app: app)
            
            screen.myDataRow.tap()
            XCTAssertTrue(app.staticTexts[verbatim: runner.scenario.didTapMyData].exists)
        }
    }
    
    func testTappingVenueHistory() throws {
        try runner.run { app in
            let screen = SettingsScreen(app: app)
            
            screen.venueHistoryRow.tap()
            XCTAssertTrue(app.staticTexts[verbatim: runner.scenario.didTapVenueHistory].exists)
        }
    }
    
    func testTappingLanguage() throws {
        try runner.run { app in
            let screen = SettingsScreen(app: app)
            
            screen.languageRow.tap()
            XCTAssertTrue(app.staticTexts[verbatim: runner.scenario.didTapLanguage].exists)
        }
    }
    
    func testDeletingAllData() throws {
        try runner.run { app in
            let screen = SettingsScreen(app: app)
            screen.deleteDataButton.tap()
            
            XCTAssertTrue(screen.deleteDataAlertConfirmationButton.exists)
            screen.deleteDataAlertConfirmationButton.tap()
            
            XCTAssertTrue(app.staticTexts[verbatim: runner.scenario.didTapDeleteAppData].exists)
        }
    }
}
