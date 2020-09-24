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
            XCTAssert(screen.screenTitle.exists)
            XCTAssert(screen.statusLabel.exists)
            XCTAssert(screen.descriptionLabel.exists)
        }
    }
    
    func testShowVenueCheckInInformation() throws {
        try runner.run { app in
            let screen = QRCodeScannerScreen(app: app)
            screen.helpButton.tap()
            XCTAssert(app.staticTexts[runner.scenario.showHelpAlertTitle].exists)
        }
    }
}
