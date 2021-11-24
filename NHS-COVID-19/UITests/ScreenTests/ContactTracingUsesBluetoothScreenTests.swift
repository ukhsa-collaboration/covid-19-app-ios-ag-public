//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class ContactTracingUsesBluetoothScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<ContactTracingUsesBluetoothScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = ContactTracingUsesBlueoothScreen(app: app)
            XCTAssertTrue(screen.title.exists)
            XCTAssertTrue(screen.description1.exists)
            XCTAssertTrue(screen.description2.exists)
            XCTAssertTrue(screen.continueButton.exists)
            XCTAssertTrue(screen.bullets.allExist)
        }
    }
    
    func testContinueButton() throws {
        try runner.run { app in
            let screen = ContactTracingUsesBlueoothScreen(app: app)
            screen.continueButton.tap()
            XCTAssertTrue(app.staticTexts[ContactTracingUsesBluetoothScreenScenario.continueButtonTapped].exists)
        }
        
    }
    
}
