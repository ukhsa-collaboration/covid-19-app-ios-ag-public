//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class QRCodeScannerScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<QRCodeScannerScreenScenario>
    
    func testPermissionRequest() throws {
        try runner.run { app in
            let screen = QRCodeScannerScreen(app: app)
            XCTAssert(app.staticTexts[runner.scenario.permissionAlertTitle].displayed)
            
            app.buttons[runner.scenario.okButtonTitle].tap()
            
            XCTAssert(screen.screenTitle.displayed)
        }
    }
    
    func testShowVenueCheckInInformation() throws {
        try runner.run { app in
            let screen = QRCodeScannerScreen(app: app)
            app.buttons[runner.scenario.okButtonTitle].tap()
            screen.helpButton.tap()
            XCTAssert(app.staticTexts[runner.scenario.showHelpAlertTitle].displayed)
        }
    }
}
