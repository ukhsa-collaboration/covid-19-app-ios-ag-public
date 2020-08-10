//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Scenarios
import TestSupport
import XCTest
@testable import Domain

class UserNotificationsStateControllerTests: XCTestCase {
    
    struct Instance: TestProp {
        struct Configuration: TestPropConfiguration {
            var manager = MockUserNotificationsManager()
            var notificationCenter = NotificationCenter()
        }
        
        var controller: UserNotificationsStateController
        
        init(configuration: Configuration) {
            controller = UserNotificationsStateController(
                manager: configuration.manager,
                notificationCenter: configuration.notificationCenter
            )
        }
    }
    
    @Propped
    private var instance: Instance
    
    private var manager: MockUserNotificationsManager {
        $instance.manager
    }
    
    private var controller: UserNotificationsStateController {
        instance.controller
    }
    
    private var notificationCenter: NotificationCenter {
        $instance.notificationCenter
    }
    
    // MARK: - Authorization status
    
    func testAuthorizationInitialStatus() {
        XCTAssertEqual(controller.authorizationStatus, .unknown)
    }
    
    func testAuthorizationNotDeterminedStatus() throws {
        try _testAuthorizationStatus(stateControllerStatus: .notDetermined, userNotificationStatus: .notDetermined)
    }
    
    func testAuthorizationDeniedStatus() throws {
        try _testAuthorizationStatus(stateControllerStatus: .denied, userNotificationStatus: .denied)
    }
    
    func testAuthorizationAuthorizedStatus() throws {
        try _testAuthorizationStatus(stateControllerStatus: .authorized, userNotificationStatus: .authorized)
    }
    
    // MARK: - Private helpers
    
    private func _testAuthorizationStatus(stateControllerStatus: UserNotificationsStateController.AuthorizationStatus, userNotificationStatus: UserNotificationManaging.AuthorizationStatus) throws {
        
        try completeUserNotificationsAuthorization(authorizationStatus: userNotificationStatus)
        
        guard case stateControllerStatus = controller.authorizationStatus else {
            throw TestError("Unexpected state \(controller.authorizationStatus). Expected state \(stateControllerStatus)")
        }
    }
    
    private func completeUserNotificationsAuthorization(
        authorizationStatus: UserNotificationManaging.AuthorizationStatus
    ) throws {
        guard case .unknown = controller.authorizationStatus else {
            throw TestError("Unexpected state \(controller.authorizationStatus)")
        }
        
        notificationCenter.post(Notification(name: UIApplication.didBecomeActiveNotification))
        manager.getSettingsCompletionHandler?(authorizationStatus)
    }
}
