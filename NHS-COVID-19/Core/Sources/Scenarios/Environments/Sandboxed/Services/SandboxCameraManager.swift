//
// Copyright © 2020 NHSX. All rights reserved.
//

import AVFoundation
import Domain
import UIKit

class SandboxCameraManager: CameraManaging {
    typealias AlertText = Sandbox.Text.CameraManager

    var instanceAuthorizationStatus: AuthorizationStatus

    private var host: SandboxHost

    init(host: SandboxHost) {
        self.host = host
        instanceAuthorizationStatus = host.initialState.cameraAuthorized ? .authorized : .notDetermined
    }

    func requestAccess(completionHandler handler: @escaping (AuthorizationStatus) -> Void) {
        showAlert(completionHandler: handler)
    }

    func createCaptureSession(handler: CaptureSessionOutputHandler) -> CaptureSession? {
        if !host.initialState.cameraUnavailable {
            if host.initialState.shouldScanQRCode {
                DispatchQueue.main.asyncAfter(deadline: .now() + host.initialState.qrCodeScanTime) {
                    handler.handleOutput(self.host.initialState.scannedQRCode)
                }
            }

            return CaptureSession(session: AVCaptureSession())
        } else {
            return nil
        }
    }

    private func showAlert(completionHandler: @escaping (AuthorizationStatus) -> Void) {
        let alert = UIAlertController(
            title: AlertText.authorizationAlertTitle.rawValue,
            message: AlertText.authorizationAlertMessage.rawValue,
            preferredStyle: .alert
        )

        alert.addAction(UIAlertAction(title: AlertText.authorizationAlertDoNotAllow.rawValue, style: .default, handler: { [weak self] _ in
            self?.instanceAuthorizationStatus = .denied
            completionHandler(.denied)
        }))

        alert.addAction(UIAlertAction(title: AlertText.authorizationAlertAllow.rawValue, style: .default, handler: { [weak self] _ in
            self?.instanceAuthorizationStatus = .authorized
            completionHandler(.authorized)
        }))
        host.container?.show(alert, sender: nil)
    }
}
