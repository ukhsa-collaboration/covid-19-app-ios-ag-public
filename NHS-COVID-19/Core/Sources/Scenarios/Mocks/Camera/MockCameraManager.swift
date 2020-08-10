//
// Copyright © 2020 NHSX. All rights reserved.
//

import Domain
import Foundation

public class MockCameraManager: CameraManaging {
    
    public var instanceAuthorizationStatus = AuthorizationStatus.notDetermined
    
    public init() {}
    
    public func requestAccess(completionHandler handler: @escaping (AuthorizationStatus) -> Void) {
        handler(instanceAuthorizationStatus)
    }
}
