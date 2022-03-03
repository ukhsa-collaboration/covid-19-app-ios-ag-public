//
// Copyright © 2022 DHSC. All rights reserved.
//

import Scenarios
import XCTest

class StartOnboardingScreenTests: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<StartOnboardingScreenScenario>
    
    func testBasicsWithVenueCheckInTurnedOn() throws {
        try runner.run { app in
            let screen = StartOnboardingScreen(app: app)
            
            XCTAssertTrue(screen.stepTitle.exists)
            XCTAssertTrue(screen.stepDescription1Header.exists)
            XCTAssertTrue(screen.stepDescription1Body.exists)
            XCTAssertTrue(screen.stepDescription2Header.exists)
            XCTAssertTrue(screen.stepDescription2Body.exists)
            XCTAssertTrue(screen.stepDescription3Header.exists)
            XCTAssertTrue(screen.stepDescription3Body.exists)
            XCTAssertTrue(screen.stepDescription4Header.exists)
            XCTAssertTrue(screen.stepDescription4Body.exists)
            XCTAssertTrue(screen.continueButton.exists)
            
        }
    }
    
    func testAgeConfirmationAccepted() throws {
        try runner.run { app in
            let screen = StartOnboardingScreen(app: app)
            screen.continueButton.tap()
            
            XCTAssert(screen.ageConfirmationAcceptButton.exists)
            screen.ageConfirmationAcceptButton.tap()
            
            let accepted = StartOnboardingScreenScenario.continueConfirmationAlertTitle
            XCTAssert(screen.ageConfirmationAlertHandled(title: accepted).exists)
        }
    }
    
    func testAgeConfirmationRejected() throws {
        try runner.run { app in
            let screen = StartOnboardingScreen(app: app)
            screen.continueButton.tap()
            
            XCTAssert(screen.ageConfirmationRejectButton.exists)
            screen.ageConfirmationRejectButton.tap()
            
            let rejected = StartOnboardingScreenScenario.rejectAlertTitle
            XCTAssert(screen.ageConfirmationAlertHandled(title: rejected).exists)
        }
    }
}

class StartOnboardingScreenTestsNoCheckIn: XCTestCase {
    
    @Propped
    private var runner: ApplicationRunner<StartOnboardingNoCheckInScreenScenario>
    
    func testBasicsWithVenueCheckInTurnedOff() throws {
        try runner.run { app in
            let screen = StartOnboardingScreen(app: app)
            
            XCTAssertTrue(screen.stepTitle.exists)
            
            // We should NOT see venue check-in but SHOULD see everything else
            XCTAssertFalse(screen.stepDescription2Header.exists)
            XCTAssertFalse(screen.stepDescription2Body.exists)
            
            // ...but SHOULD see everything else
            XCTAssertTrue(screen.stepDescription1Header.exists)
            XCTAssertTrue(screen.stepDescription1Body.exists)
            XCTAssertTrue(screen.stepDescription3Header.exists)
            XCTAssertTrue(screen.stepDescription3Body.exists)
            XCTAssertTrue(screen.stepDescription4Header.exists)
            XCTAssertTrue(screen.stepDescription4Body.exists)
            XCTAssertTrue(screen.continueButton.exists)
            
        }
    }
}
