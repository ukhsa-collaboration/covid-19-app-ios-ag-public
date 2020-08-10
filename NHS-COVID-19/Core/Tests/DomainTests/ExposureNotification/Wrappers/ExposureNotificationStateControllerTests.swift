//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import TestSupport
import XCTest
@testable import Domain

class ExposureNotificationStateControllerTests: XCTestCase {
    
    struct Instance: TestProp {
        struct Configuration: TestPropConfiguration {
            var manager = MockExposureNotificationManager()
        }
        
        var controller: ExposureNotificationStateController
        
        init(configuration: Configuration) {
            controller = ExposureNotificationStateController(manager: configuration.manager)
        }
    }
    
    @Propped
    private var instance: Instance
    
    private var manager: MockExposureNotificationManager {
        $instance.manager
    }
    
    private var controller: ExposureNotificationStateController {
        instance.controller
    }
    
    // MARK: - Activation state
    
    func testStartsInactive() {
        XCTAssertEqual(controller.activationState, .inactive)
    }
    
    func testActivating() {
        controller.activate()
        
        XCTAssertEqual(controller.activationState, .activating)
    }
    
    func testActivated() {
        controller.activate()
        manager.activationCompletionHandler?(nil)
        
        XCTAssertEqual(controller.activationState, .activated)
    }
    
    func testActivationFailed() {
        controller.activate()
        manager.activationCompletionHandler?(TestError(""))
        
        XCTAssertEqual(controller.activationState, .activationFailed)
    }
    
    // MARK: - Authorization state
    
    func testInitialAuthorizationState() {
        for (controllerState, managerState) in authorizationStatusPairs {
            manager.instanceAuthorizationStatus = managerState
            XCTAssertEqual(controller.authorizationState, controllerState)
            _instance.reset()
        }
    }
    
    func testAuthorizationStateUpdatesAfterActivation() {
        for (controllerState, managerState) in authorizationStatusPairs {
            controller.activate()
            manager.instanceAuthorizationStatus = managerState
            manager.activationCompletionHandler?(nil)
            XCTAssertEqual(controller.authorizationState, controllerState)
            _instance.reset()
        }
    }
    
    func testAuthorizationStateUpdatesAfterEnablingAllowed() {
        controller.activate()
        manager.activationCompletionHandler?(nil)
        controller.enable(completion: {})
        manager.instanceAuthorizationStatus = .authorized
        manager.setExposureNotificationEnabledCompletionHandler?(nil)
        XCTAssertEqual(controller.authorizationState, .authorized)
    }
    
    func testAuthorizationStateUpdatesAfterEnablingNotAllowed() {
        controller.activate()
        manager.activationCompletionHandler?(nil)
        controller.enable(completion: {})
        manager.instanceAuthorizationStatus = .notAuthorized
        manager.setExposureNotificationEnabledCompletionHandler?(TestError(""))
        XCTAssertEqual(controller.authorizationState, .notAuthorized)
    }
    
    // MARK: - State
    
    func testInitialState() {
        for (controllerState, managerState) in statusPairs {
            manager.exposureNotificationStatus = managerState
            XCTAssertEqual(controller.exposureNotificationState, controllerState)
            _instance.reset()
        }
    }
    
    func testStateUpdates() {
        for (controllerState, managerState) in statusPairs {
            XCTAssertEqual(controller.exposureNotificationState, .unknown)
            manager.exposureNotificationStatus = managerState
            XCTAssertEqual(controller.exposureNotificationState, controllerState)
            _instance.reset()
        }
    }
    
    // MARK: - Enabling
    
    func testInitiallyEnabled() {
        manager.exposureNotificationEnabled = true
        XCTAssert(controller.isEnabled)
    }
    
    func testInitiallyDisabled() {
        manager.exposureNotificationEnabled = false
        XCTAssertFalse(controller.isEnabled)
    }
    
    func testEnabledValueUpdates() {
        XCTAssertFalse(controller.isEnabled)
        manager.exposureNotificationEnabled = true
        XCTAssert(controller.isEnabled)
    }
    
    func testEnablingSetsTheFlagAsPositive() {
        controller.activate()
        manager.activationCompletionHandler?(nil)
        controller.enable(completion: {})
        XCTAssertEqual(manager.setExposureNotificationEnabledValue, true)
    }
    
    func testSettingEnabledUpdatesEnabledState() {
        controller.activate()
        let cancellable = controller.setEnabled(true).sink {}
        XCTAssertEqual(manager.setExposureNotificationEnabledValue, true)
        cancellable.cancel()
    }
}

private let authorizationStatusPairs: [(ExposureNotificationStateController.AuthorizationState, ExposureNotificationManaging.AuthorizationStatus)] = [
    (.unknown, .unknown),
    (.restricted, .restricted),
    (.notAuthorized, .notAuthorized),
    (.authorized, .authorized),
]

private let statusPairs: [(ExposureNotificationStateController.State, ExposureNotificationManaging.Status)] = [
    (.unknown, .unknown),
    (.active, .active),
    (.disabled, .disabled),
    (.bluetoothOff, .bluetoothOff),
    (.restricted, .restricted),
]
