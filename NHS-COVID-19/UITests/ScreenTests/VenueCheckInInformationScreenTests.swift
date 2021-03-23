//
// Copyright © 2021 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class VenueCheckInInformationScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<VenueCheckInInformationScreenScenario>
    
    func testBasics() throws {
        try runner.run { app in
            let screen = VenueCheckInInformationScreen(app: app)
            
            XCTAssert(screen.screenTitle.exists)
            XCTAssert(screen.helpScanningTitle.exists)
            XCTAssert(screen.helpScanningDescription.exists)
            XCTAssert(screen.whatsAQRCodeTitle.exists)
            XCTAssert(screen.whatsAQRCodeDescription.exists)
            XCTAssert(screen.qrCodePosterDescription.exists)
            XCTAssert(screen.qrCodePosterImage.exists)
            XCTAssert(screen.qrCodePosterDescriptionWLS.exists)
            XCTAssert(screen.qrCodePosterImageWLS.exists)
            XCTAssert(screen.howItWorksTitle.exists)
            XCTAssert(screen.howItWorksDescription.exists)
            XCTAssert(screen.cancelButton.exists)
        }
    }
    
    func tapCancel() throws {
        try runner.run { app in
            let screen = VenueCheckInInformationScreen(app: app)
            
            screen.cancelButton.tap()
            
            XCTAssert(screen.dismissAlert.exists)
        }
    }
    
}
