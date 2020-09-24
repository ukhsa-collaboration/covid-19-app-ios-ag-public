//
// Copyright © 2020 NHSX. All rights reserved.
//

import AVFoundation
import Domain
import Foundation

public class MockCameraManager: CameraManaging {
    
    public var instanceAuthorizationStatus = AuthorizationStatus.notDetermined
    public var receivedHandler: CaptureSessionOutputHandler?
    
    public init() {}
    
    public func requestAccess(completionHandler handler: @escaping (AuthorizationStatus) -> Void) {
        handler(instanceAuthorizationStatus)
    }
    
    public func createCaptureSession(handler: CaptureSessionOutputHandler) -> CaptureSession? {
        receivedHandler = handler
        return CaptureSession(session: AVCaptureSession())
    }
}
