//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Domain
import Scenarios
import TestSupport
import XCTest

class CameraStateControllerTests: XCTestCase {

    struct Instance: TestProp {
        struct Configuration: TestPropConfiguration {
            var manager = MockCameraManager()
            var notificationCenter = NotificationCenter()
        }

        var controller: CameraStateController

        init(configuration: Configuration) {
            controller = CameraStateController(
                manager: configuration.manager,
                notificationCenter: configuration.notificationCenter
            )
        }
    }

    @Propped
    private var instance: Instance

    private var manager: MockCameraManager {
        $instance.manager
    }

    private var controller: CameraStateController {
        instance.controller
    }

    private var notificationCenter: NotificationCenter {
        $instance.notificationCenter
    }

    // MARK: - Authorization status

    func testAuthorizationInitialState() {
        XCTAssertEqual(controller.authorizationState, .notDetermined)
    }

    func testAuthorizationNotDeterminedState() throws {
        try _testAuthorizationStatus(stateControllerState: .notDetermined, cameraAuthorizationStatus: .notDetermined)
    }

    func testAuthorizationDeniedState() throws {
        try _testAuthorizationStatus(stateControllerState: .denied, cameraAuthorizationStatus: .denied)
    }

    func testAuthorizationAuthorizedState() throws {
        try _testAuthorizationStatus(stateControllerState: .authorized, cameraAuthorizationStatus: .authorized)
    }

    // MARK: - Private helpers

    private func _testAuthorizationStatus(stateControllerState: CameraStateController.AuthorizationState, cameraAuthorizationStatus: CameraManaging.AuthorizationStatus) throws {

        try completeCameraAuthorization(authorizationStatus: cameraAuthorizationStatus)

        guard case stateControllerState = controller.authorizationState else {
            throw TestError("Unexpected state \(controller.authorizationState). Expected state \(stateControllerState)")
        }
    }

    private func completeCameraAuthorization(
        authorizationStatus: CameraManaging.AuthorizationStatus
    ) throws {
        guard case .notDetermined = controller.authorizationState else {
            throw TestError("Unexpected state \(controller.authorizationState)")
        }

        manager.instanceAuthorizationStatus = authorizationStatus
        notificationCenter.post(Notification(name: UIApplication.didBecomeActiveNotification))
    }
}
