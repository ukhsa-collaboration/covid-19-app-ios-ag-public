//
// Copyright © 2021 DHSC. All rights reserved.
//

import XCTest

extension XCUIApplication {
    func checkOnHomeScreen(postcode: String, alertLevel: Int = 1) {
        let homeScreen = HomeScreen(app: self)
        
        #warning("Remove this after resolving the accessiblity hack for iOS 14 in HomeViewController")
        /*
         The accessibility hack for iOS 14 in HomeViewController adds a flickering to the home screen. Because of
         this, the check for the riskLevelBanner fails, if coming from a negative test result. This flow will, after
         acknowledging the result, immediately go back to the home screen unlike the positive and void flow.
         */
        XCTAssert(homeScreen.riskLevelBanner(for: postcode, title: "[postcode] is in Local Alert Level \(alertLevel)").waitForExistence(timeout: 2.0))
    }
    
    func checkOnHomeScreenNotIsolating() {
        let homeScreen = HomeScreen(app: self)
        
        #warning("Remove this after resolving the accessiblity hack for iOS 14 in HomeViewController")
        /*
         The accessibility hack for iOS 14 in HomeViewController adds a flickering to the home screen. Because of
         this, the check for the riskLevelBanner fails, if coming from a negative test result. This flow will, after
         acknowledging the result, immediately go back to the home screen unlike the positive and void flow.
         */
        XCTAssert(homeScreen.notIsolatingIndicator.waitForExistence(timeout: 2.0))
    }
    
    func checkOnHomeScreenIsolatingWarning(date: Date, days: Int) {
        let homeScreen = HomeScreen(app: self)
        
        #warning("Remove this after resolving the accessiblity hack for iOS 14 in HomeViewController")
        /*
         The accessibility hack for iOS 14 in HomeViewController adds a flickering to the home screen. Because of
         this, the check for the riskLevelBanner fails, if coming from a negative test result. This flow will, after
         acknowledging the result, immediately go back to the home screen unlike the positive and void flow.
         */
        XCTAssert(homeScreen.isolatingIndicatorWarning(date: date, days: days).waitForExistence(timeout: 2.0))
    }
    
    func checkOnHomeScreenIsolatingInformational(date: Date, days: Int) {
        let homeScreen = HomeScreen(app: self)
        
        #warning("Remove this after resolving the accessiblity hack for iOS 14 in HomeViewController")
        /*
         The accessibility hack for iOS 14 in HomeViewController adds a flickering to the home screen. Because of
         this, the check for the riskLevelBanner fails, if coming from a negative test result. This flow will, after
         acknowledging the result, immediately go back to the home screen unlike the positive and void flow.
         */
        XCTAssert(homeScreen.isolatingIndicatorInformational(date: date, days: days).waitForExistence(timeout: 2.0))
    }

    
    func checkOnHomeScreen(with element: XCUIElement) {
        #warning("Remove this after resolving the accessiblity hack for iOS 14 in HomeViewController")
        /*
         The accessibility hack for iOS 14 in HomeViewController adds a flickering to the home screen. Because of
         this, the check for the riskLevelBanner fails, if coming from a negative test result. This flow will, after
         acknowledging the result, immediately go back to the home screen unlike the positive and void flow.
         */
        XCTAssert(element.waitForExistence(timeout: 2.0))
    }
    
    func checkOnHomeScreenBluetoothOff() {
        let homeScreen = HomeScreen(app: self)
        XCTAssert(homeScreen.contactTracingDoesNotWorkWithBTOffLabel.exists)
    }
    
}
