//
// Copyright © 2020 NHSX. All rights reserved.
//

import AVFoundation
import Combine
import Foundation
import UIKit

public class CameraStateController: ObservableObject {

    public enum AuthorizationState {
        case notDetermined
        case authorized
        case denied
        case restricted
    }

    @Published
    public private(set) var authorizationState: AuthorizationState

    private let manager: CameraManaging
    private var cancellable: AnyCancellable?

    public init(manager: CameraManaging, notificationCenter: NotificationCenter) {
        self.manager = manager
        authorizationState = CameraStateController.AuthorizationState(manager.instanceAuthorizationStatus)
        cancellable = notificationCenter.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] notification in
                self?.authorizationState = CameraStateController.AuthorizationState(manager.instanceAuthorizationStatus)
            }
    }

    public func requestAccess() {
        assert(authorizationState == .notDetermined, "\(#function) must be called at most once.")
        manager.requestAccess {
            self.authorizationState = CameraStateController.AuthorizationState($0)
        }
    }
}

private extension CameraStateController.AuthorizationState {

    init(_ status: AVAuthorizationStatus) {
        switch status {
        case .restricted:
            self = .restricted
        case .notDetermined:
            self = .notDetermined
        case .authorized:
            self = .authorized
        case .denied:
            self = .denied
        @unknown default:
            assertionFailure("Unexpected status \(status)")
            self = .denied
        }
    }
}
