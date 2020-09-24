//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class ShareKeysConfirmationScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<ShareKeysConfirmationScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = ShareKeysConfirmationScreen(app: app)
            
            XCTAssert(screen.title.exists)
            XCTAssert(screen.heading.exists)
            XCTAssert(screen.informationTitle.exists)
            XCTAssert(screen.informationBody.exists)
            XCTAssert(screen.iUnderstand.exists)
            XCTAssert(screen.back.exists)
        }
    }
    
    func testTapIUnderstand() throws {
        try runner.run { app in
            let screen = ShareKeysConfirmationScreen(app: app)
            
            screen.iUnderstand.tap()
            let alert = screen.iUnderstandAlert(ShareKeysConfirmationScreenScenario.iUnderstandTapped)
            XCTAssert(alert.exists)
        }
    }
    
    func testTapBack() throws {
        try runner.run { app in
            let screen = ShareKeysConfirmationScreen(app: app)
            
            screen.back.tap()
            let alert = screen.iUnderstandAlert(ShareKeysConfirmationScreenScenario.backTapped)
            XCTAssert(alert.exists)
        }
    }
}
