//
// Copyright © 2020 NHSX. All rights reserved.
//

import AVFoundation
import Combine
import Common
import Domain
import Integration
import Interface
import UIKit

public class CheckInFlowScenario: Scenario {
    
    public static var name = "Check In"
    public static var kind = ScenarioKind.flow
    
    public static let cameraPermissionAlertTitle = "Camera Permission"
    public static let allowAlertButton = "Allow"
    public static let denyAlertButton = "Don’t Allow"
    
    static var appController: AppController {
        Controller()
    }
    
    private class Controller: AppController {
        
        let rootViewController = UIViewController()
        
        init() {
            let manager = CameraManager()
            let controller = CameraStateController(manager: manager, notificationCenter: .default)
            let interactor = Interactor(
                viewController: rootViewController,
                manager: manager,
                controller: controller
            )
            let cameraPermissionStatePublisher = controller.$authorizationState.map { state -> CameraPermissionState in
                switch state {
                case .notDetermined:
                    return .notDetermined
                case .authorized:
                    return .authorized
                case .denied, .restricted:
                    return .denied
                }
            }.eraseToAnyPublisher()
            let flow = CheckInFlowViewController(
                cameraPermissionState: cameraPermissionStatePublisher,
                interactor: interactor
            )
            rootViewController.addFilling(flow)
        }
    }
    
    private class Interactor: CheckInFlowViewController.Interacting {
        
        private weak var viewController: UIViewController?
        private let manager: CameraManager
        private let controller: CameraStateController
        
        init(viewController: UIViewController, manager: CameraManager, controller: CameraStateController) {
            self.viewController = viewController
            self.controller = controller
            self.manager = manager
        }
        
        func requestCameraAccess() {
            controller.requestAccess()
            let alert = UIAlertController(
                title: CheckInFlowScenario.cameraPermissionAlertTitle,
                message: "[FAKE] This alert only simulates the system alert.",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "Don’t Allow", style: .default, handler: { [weak self] _ in
                self?.manager.controlledAuthorizationStatus = .denied
            }))
            alert.addAction(UIAlertAction(title: "Allow", style: .default, handler: { [weak self] _ in
                self?.manager.controlledAuthorizationStatus = .authorized
            }))
            viewController?.present(alert, animated: false, completion: nil)
        }
        
        func openSettings() {
            let alert = UIAlertController(
                title: nil,
                message: "Open Settings",
                preferredStyle: .alert
            )
            alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { _ in }))
            viewController?.present(alert, animated: false, completion: nil)
        }
        
        func createCaptureSession(resultHandler: ([AVMetadataMachineReadableCodeObject]) -> Void) -> AVCaptureSession? {
            return nil
        }
        
        func process(_ payload: String) -> CheckInDetail {
            CheckInDetail(venueName: "Some Venue", removeCurrentCheckIn: {})
        }
        
        func removeCurrentCheckin() {}
    }
    
    private class CameraManager: CameraManaging {
        
        var controlledAuthorizationStatus = AuthorizationStatus.notDetermined {
            didSet {
                handler?(controlledAuthorizationStatus)
            }
        }
        
        var handler: ((AuthorizationStatus) -> Void)?
        
        var instanceAuthorizationStatus: AuthorizationStatus {
            controlledAuthorizationStatus
        }
        
        func requestAccess(completionHandler handler: @escaping (AuthorizationStatus) -> Void) {
            self.handler = handler
        }
        
        func createCaptureSession(handler: CaptureSessionOutputHandler) -> AVCaptureSession? {
            return nil
        }
        
    }
    
}
