//
// Copyright © 2020 NHSX. All rights reserved.
//

import XCTest

extension XCUIApplication {
    func checkBackOnHomeScreen(postcode: String) {
        let homeScreen = HomeScreen(app: self)
        
        #warning("Remove this after resolving the accessiblity hack for iOS 14 in HomeViewController")
        /*
         The accessibility hack for iOS 14 in HomeViewController adds a flickering to the home screen. Because of
         this, the check for the riskLevelBanner fails, if coming from a negative test result. This flow will, after
         acknowledging the result, immediately go back to the home screen unlike the positive and void flow.
         */
        XCTAssert(homeScreen.riskLevelBanner(for: postcode, title: "[postcode] is in Local Alert Level 1").waitForExistence(timeout: 2.0))
    }
}
