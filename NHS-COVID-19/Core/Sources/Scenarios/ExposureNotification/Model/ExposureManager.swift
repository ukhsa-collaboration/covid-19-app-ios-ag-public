//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import ExposureNotification
import Foundation

class ExposureManager: ObservableObject {

    enum AuthorizationState {
        case notDetermined(enable: () -> Void)
        case notAuthorized(isRestricted: Bool)
        case authorized(EnabledExposureManager)
    }

    enum ActivationState {
        case activating
        case activated
        case activationFailed(Error)
    }

    private let manager = ENManager()

    @Published
    private(set) var activationState = ActivationState.activating

    @Published
    private(set) var authorizationState = AuthorizationState.notDetermined(enable: {})

    @Published
    private(set) var isEnabled = false

    init() {
        activate()
        updateAuthorizationState()
    }

    private func activate() {
        manager.activate { error in
            if let error = error {
                self.activationState = .activationFailed(error)
            } else {
                self.activationState = .activated
                self.didActivate()
            }
        }
    }

    private func didActivate() {
        updateAuthorizationState()
        if case .authorized = authorizationState, !isEnabled {
            enable()
        }
    }

    private func updateAuthorizationState() {
        authorizationState = determineAuthorizationState()
        isEnabled = manager.exposureNotificationEnabled
    }

    private func determineAuthorizationState() -> AuthorizationState {
        switch ENManager.authorizationStatus {
        case .unknown:
            return .notDetermined(enable: { [weak self] in self?.enable() })
        case .restricted:
            return .notAuthorized(isRestricted: true)
        case .notAuthorized:
            return .notAuthorized(isRestricted: false)
        case .authorized:
            return .authorized(EnabledExposureManager(manager: manager))
        @unknown default:
            fatalError()
        }
    }

    private func enable() {
        manager.setExposureNotificationEnabled(true) { _ in
            self.updateAuthorizationState()
        }
    }

    deinit {
        manager.invalidate()
    }

}

extension ExposureManager {

    private func completeActivation() -> AnyPublisher<Void, Error> {
        $activationState
            .setFailureType(to: Error.self)
            .compactMap { state -> Result<Void, Error>? in
                switch state {
                case .activating:
                    return nil
                case .activated:
                    return .success(())
                case .activationFailed(let error):
                    return .failure(error)
                }
            }
            .flatMap { $0.publisher }
            .first()
            .eraseToAnyPublisher()
    }

    private func completeAuthorization() -> AnyPublisher<EnabledExposureManager, Error> {
        if case .notDetermined(let enable) = authorizationState {
            enable()
        }

        return $authorizationState
            .setFailureType(to: Error.self)
            .compactMap { state -> Result<EnabledExposureManager, Error>? in
                switch state {
                case .notDetermined:
                    return nil
                case .notAuthorized:
                    return .failure(SimpleError("Exposure Notification not authorized."))
                case .authorized(let manager):
                    return .success(manager)
                }
            }
            .flatMap { $0.publisher }
            .first()
            .eraseToAnyPublisher()
    }

    private func completeEnabling() -> AnyPublisher<Void, Error> {
        if !isEnabled {
            enable()
        }

        return $isEnabled.first { $0 }
            .map { _ in }
            .setFailureType(to: Error.self)
            .eraseToAnyPublisher()
    }

    func enabledManager() -> AnyPublisher<EnabledExposureManager, Error> {
        completeActivation()
            .flatMap { self.completeAuthorization() }
            .flatMap { manager in
                // TODO: We should really get the manager from the enabled step.
                self.completeEnabling().map { manager }
            }
            .eraseToAnyPublisher()
    }

}
