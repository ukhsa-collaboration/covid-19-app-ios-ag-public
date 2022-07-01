//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Foundation
import UIKit
import UserNotifications

class UserNotificationsStateController {

    enum AuthorizationStatus: Equatable {
        case unknown
        case notDetermined
        case denied
        case authorized
    }

    @Published
    private(set) var authorizationStatus = AuthorizationStatus.unknown

    private let manager: UserNotificationManaging
    private var cancellable: AnyCancellable?

    init(manager: UserNotificationManaging, notificationCenter: NotificationCenter) {
        self.manager = manager

        updateStatus()
        cancellable = notificationCenter.publisher(for: UIApplication.didBecomeActiveNotification)
            .sink { [weak self] notification in
                self?.updateStatus()
            }
    }

    func authorize() {
        if authorizationStatus == .notDetermined {
            manager.requestAuthorization(options: [.alert, .sound, .badge]) { [weak self] _, error in
                self?.updateStatus()
            }
        }
    }

    func recordMetrics() -> AnyPublisher<Void, Never> {
        if case .authorized = authorizationStatus {
            Metrics.signpost(.hasRiskyContactNotificationsEnabledBackgroundTick)
        }

        return Empty().eraseToAnyPublisher()
    }

    // MARK: - Private helpers

    private func updateStatus() {
        manager.getAuthorizationStatus { authorizationStatus in
            switch authorizationStatus {
            case .notDetermined:
                self.authorizationStatus = .notDetermined
            case .authorized:
                self.authorizationStatus = .authorized
            case .denied:
                self.authorizationStatus = .denied
            case .provisional, .ephemeral:
                assertionFailure("these should not happen")
                self.authorizationStatus = .denied
            @unknown default:
                self.authorizationStatus = .authorized
            }
        }
    }
}
