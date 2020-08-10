//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation

public protocol ExposureNotificationStateControlling {
    func setEnabled(_ enabled: Bool) -> AnyPublisher<Void, Never>
    var isEnabledPublisher: AnyPublisher<Bool, Never> { get }
}

extension ExposureNotificationStateController: ExposureNotificationStateControlling {
    var isEnabledPublisher: AnyPublisher<Bool, Never> {
        $isEnabled.eraseToAnyPublisher()
    }
}

class ExposureNotificationStateController: ObservableObject {
    
    enum ActivationState {
        case inactive
        case activating
        case activationFailed
        case activated
    }
    
    enum AuthorizationState {
        case unknown
        case restricted
        case notAuthorized
        case authorized
    }
    
    enum State {
        case unknown
        case active
        case disabled
        case bluetoothOff
        case restricted
    }
    
    struct CombinedState: Equatable {
        var activationState: ActivationState
        var authorizationState: AuthorizationState
        var exposureNotificationState: State
        var isEnabled: Bool
    }
    
    private let manager: ExposureNotificationManaging
    private var cancellables = [AnyCancellable]()
    
    @Published
    private(set) var activationState = ActivationState.inactive
    
    @Published
    private(set) var authorizationState: AuthorizationState
    
    @Published
    private(set) var exposureNotificationState = State.unknown
    
    @Published
    private(set) var isEnabled = false
    
    var combinedState: AnyPublisher<CombinedState, Never> {
        $activationState
            .combineLatest(
                $authorizationState,
                $exposureNotificationState,
                $isEnabled
            )
            .map(CombinedState.init)
            .removeDuplicates()
            .eraseToAnyPublisher()
    }
    
    init(manager: ExposureNotificationManaging) {
        self.manager = manager
        authorizationState = AuthorizationState(manager.instanceAuthorizationStatus)
        
        manager.exposureNotificationStatusPublisher.sink { [weak self] in
            self?.exposureNotificationState = State($0)
        }.store(in: &cancellables)
        
        manager.exposureNotificationEnabledPublisher.sink { [weak self] in
            self?.isEnabled = $0
        }.store(in: &cancellables)
    }
    
    func activate() {
        assert(activationState == .inactive, "\(#function) must be called at most once.")
        
        activationState = .activating
        manager.activate { error in
            self.activationState = (error == nil) ? .activated : .activationFailed
            self.authorizationState = AuthorizationState(self.manager.instanceAuthorizationStatus)
        }
    }
    
    func setEnabled(_ enabled: Bool, completion: @escaping () -> Void) {
        manager.setExposureNotificationEnabled(enabled) { _ in
            self.authorizationState = AuthorizationState(self.manager.instanceAuthorizationStatus)
            completion()
        }
    }
    
    func setEnabled(_ enabled: Bool) -> AnyPublisher<Void, Never> {
        Future { [weak self] promise in
            self?.setEnabled(enabled) {
                promise(.success(()))
            }
        }
        .eraseToAnyPublisher()
    }
    
    func enable(completion: @escaping () -> Void) {
        setEnabled(true, completion: completion)
    }
    
    func disable(completion: @escaping () -> Void) {
        setEnabled(false, completion: completion)
    }
    
    func recordMetrics() -> AnyPublisher<Void, Never> {
        Metrics.signpost(.runningNormallyTick)
        if !isEnabled {
            Metrics.signpost(.pauseTick)
        }
        
        return Empty().eraseToAnyPublisher()
    }
}

private extension ExposureNotificationStateController.AuthorizationState {
    
    init(_ status: ExposureNotificationManaging.AuthorizationStatus) {
        switch status {
        case .unknown:
            self = .unknown
        case .restricted:
            self = .restricted
        case .notAuthorized:
            self = .notAuthorized
        case .authorized:
            self = .authorized
        @unknown default:
            assertionFailure("Unexpected status \(status)")
            self = .unknown
        }
    }
    
}

private extension ExposureNotificationStateController.State {
    
    init(_ status: ExposureNotificationManaging.Status) {
        switch status {
        case .unknown:
            self = .unknown
        case .active:
            self = .active
        case .disabled:
            self = .disabled
        case .bluetoothOff:
            self = .bluetoothOff
        case .restricted:
            self = .restricted
        @unknown default:
            assertionFailure("Unexpected status \(status)")
            self = .unknown
        }
    }
    
}
