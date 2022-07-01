//
// Copyright © 2021 DHSC. All rights reserved.
//

import AVFoundation
import Domain
import Foundation

public class MockCameraManager: CameraManaging {

    public var instanceAuthorizationStatus: AVAuthorizationStatus
    public var receivedHandler: CaptureSessionOutputHandler?

    public init(authorizationStatus: AVAuthorizationStatus = AuthorizationStatus.notDetermined) {
        instanceAuthorizationStatus = authorizationStatus
    }

    public func requestAccess(completionHandler handler: @escaping (AuthorizationStatus) -> Void) {
        handler(instanceAuthorizationStatus)
    }

    public func createCaptureSession(handler: CaptureSessionOutputHandler) -> CaptureSession? {
        receivedHandler = handler

        DispatchQueue.main.asyncAfter(deadline: .now() + 2) { [weak self] in
            self?.receivedHandler?.handleOutput("ignored venue id") // this venue id is ignored as we assume we're also using MockVenueDecoder
        }

        return CaptureSession(session: AVCaptureSession())
    }
}
