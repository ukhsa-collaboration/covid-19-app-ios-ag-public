//
// Copyright © 2020 NHSX. All rights reserved.
//

import AVFoundation
import Foundation

public protocol CameraManaging {
    typealias AuthorizationStatus = AVAuthorizationStatus
    
    var instanceAuthorizationStatus: AuthorizationStatus { get }
    
    func requestAccess(completionHandler handler: @escaping (AuthorizationStatus) -> Void)
}

public class CameraManager: CameraManaging {
    
    public init() {}
    
    public var instanceAuthorizationStatus: AuthorizationStatus {
        AVCaptureDevice.authorizationStatus(for: .video)
    }
    
    public func requestAccess(completionHandler handler: @escaping (AuthorizationStatus) -> Void) {
        AVCaptureDevice.requestAccess(for: .video) { _ in
            handler(self.instanceAuthorizationStatus)
        }
    }
    
}
