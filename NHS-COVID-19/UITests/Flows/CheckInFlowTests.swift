//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

class NewCheckInFlowTests: XCTestCase {
    @Propped
    private var runner: ApplicationRunner<CheckInFlowScenario>
    
    func testUnhappyPathNotSupported() throws {
        $runner.report("Unhappy path") {
            """
            User gives the camera permission and can checkin
            """
        }
        
//        $runner.initialState.isPilotActivated = true
        
        try runner.run { app in
            
            XCTAssert(app.alerts[runner.scenario.cameraPermissionAlertTitle].exists)
            
            runner.step("Permission Alert") {
                """
                The user is presented a permisson popup by the system to request access to the camera.
                The user agrees but camera can not start.
                """
            }
            
            app.buttons[runner.scenario.allowAlertButton].tap()
            let failureScreen = CameraFailureScreen(app: app)
            XCTAssert(failureScreen.screenTitle.exists)
            XCTAssert(failureScreen.screenDescription.exists)
            
            runner.step("Permission Authorized but Camera Failed to start") {
                """
                The user is a error screen.
                """
            }
        }
    }
}

class CheckInFlowTests: XCTestCase {
    @Propped
    private var runner: ApplicationRunner<CheckInFlowScenario>
    
    func testUnhappyPathNotSupported() throws {
        $runner.report("Unhappy path") {
            """
            User gives the camera permission and can checkin
            """
        }
        try runner.run { app in
            XCTAssert(app.alerts[runner.scenario.cameraPermissionAlertTitle].exists)
            
            runner.step("Permission Alert") {
                """
                The user is presented a permisson popup by the system to request access to the camera.
                The user agrees but camera can not start.
                """
            }
            
            app.buttons[runner.scenario.allowAlertButton].tap()
            let failureScreen = CameraFailureScreen(app: app)
            XCTAssert(failureScreen.screenTitle.exists)
            XCTAssert(failureScreen.screenDescription.exists)
            
            runner.step("Permission Authorized but Camera Failed to start") {
                """
                The user is a error screen.
                """
            }
        }
    }
    
    func testUnhappyPathAccessDenied() throws {
        $runner.report("Unhappy path") {
            """
            User denies the camera permission and sees the denial screen
            """
        }
        try runner.run { app in
            XCTAssert(app.alerts[runner.scenario.cameraPermissionAlertTitle].exists)
            
            runner.step("Permission Alert") {
                """
                The user is presented a permisson popup by the system to request access to the camera.
                The user agrees.
                """
            }
            
            app.buttons[runner.scenario.denyAlertButton].tap()
            let denialScreen = CameraAccessDeniedScreen(app: app)
            XCTAssert(denialScreen.screenTitle.exists)
            XCTAssert(denialScreen.screenDescription.exists)
            
            runner.step("Permission Denial") {
                """
                The user is shown a permisson denial screen with the possibility to go to the settings.
                """
            }
        }
    }
}
