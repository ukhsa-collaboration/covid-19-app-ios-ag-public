//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Integration
import Interface
import UIKit

public class QRCodeScannerScreenScenario: Scenario {
    public static let name = "CheckIn - QR Code Scanner"
    public static let kind = ScenarioKind.screen
    
    public static let permissionAlertTitle = "Should request for camera permisson."
    public static let showHelpAlertTitle = "Should show venue check in information."
    public static let okButtonTitle = "OK"
    
    static var appController: AppController {
        let parent = UINavigationController()
        parent.isNavigationBarHidden = true
        
        let mock = MockQRCodeScanner()
        let scanner = QRScanner(
            state: mock.getState().map { state in
                switch state {
                case .starting:
                    return .starting
                case .failed:
                    return .failed
                case .requestingPermission:
                    return .requestingPermission
                case .running:
                    return .running
                case .scanning:
                    return .scanning
                case .processing:
                    return .processing
                case .stopped:
                    return .stopped
                }
            }.eraseToAnyPublisher(),
            startScanning: mock.startScanner,
            stopScanning: mock.stopScanner,
            layoutFinished: mock.changeOrientation
        )
        let viewController = Interface.QRCodeScannerViewController(
            interactor: Interactor(viewController: parent),
            cameraPermissionState: Just(CameraPermissionState.notDetermined).eraseToAnyPublisher(),
            scanner: scanner,
            completion: { _ in }
        )
        parent.pushViewController(viewController, animated: false)
        return BasicAppController(rootViewController: parent)
    }
    
    private class Interactor: Interface.QRCodeScannerViewController.Interacting {
        var viewController: UIViewController?
        init(viewController: UIViewController) {
            self.viewController = viewController
        }
        
        func showHelp() {
            viewController?.showAlert(title: QRCodeScannerScreenScenario.showHelpAlertTitle)
        }
        
    }
}
