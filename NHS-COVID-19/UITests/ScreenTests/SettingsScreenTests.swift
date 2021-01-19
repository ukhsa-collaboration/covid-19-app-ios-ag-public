//
// Copyright © 2020 NHSX. All rights reserved.
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
            XCTAssertEqual(screen.languageRow.stringValue, runner.scenario.language)
        }
    }
    
    func testTappingLanguage() throws {
        try runner.run { app in
            let screen = SettingsScreen(app: app)
            
            screen.languageRow.tap()
            XCTAssertTrue(app.staticTexts[verbatim: runner.scenario.didTapLanguage].exists)
        }
    }
}
