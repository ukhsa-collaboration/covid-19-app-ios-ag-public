//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common

protocol ExposureInfoProvider {
    var exposureInfo: ExposureInfo? { get nonmutating set }
}

protocol RiskyCheckinsProvider {
    var riskyCheckIns: [CheckIn] { get }
    var riskApprovalTokens: [String: CircuitBreakerApprovalToken] { get nonmutating set }
    func set(_ approval: CircuitBreakerApproval, for venueId: String)
}

extension ExposureDetectionStore: ExposureInfoProvider {}
extension CheckInsStore: RiskyCheckinsProvider {}

class CircuitBreaker {
    public var showDontWorryNotificationIfNeeded = false
    
    private let client: CircuitBreakingClient
    private let exposureInfoProvider: ExposureInfoProvider
    private let riskyCheckinsProvider: RiskyCheckinsProvider
    private let handleContactCase: (RiskInfo) -> Void
    private let handleDontWorryNotification: () -> Void
    
    private enum Resolution: Equatable {
        case proceed
        case ignore
        case askAgain(CircuitBreakerApprovalToken)
    }
    
    init(
        client: CircuitBreakingClient,
        exposureInfoProvider: ExposureInfoProvider,
        riskyCheckinsProvider: RiskyCheckinsProvider,
        handleContactCase: @escaping (RiskInfo) -> Void,
        handleDontWorryNotification: @escaping () -> Void
    ) {
        self.client = client
        self.exposureInfoProvider = exposureInfoProvider
        self.riskyCheckinsProvider = riskyCheckinsProvider
        self.handleContactCase = handleContactCase
        self.handleDontWorryNotification = handleDontWorryNotification
    }
    
    func processPendingApprovals() -> AnyPublisher<Void, Never> {
        Publishers.Merge(
            processExposureNotificationApproval(),
            processRiskyVenueApproval()
        )
        .eraseToAnyPublisher()
    }
    
    func processExposureNotificationApproval() -> AnyPublisher<Void, Never> {
        guard let riskInfo = exposureInfoProvider.exposureInfo?.riskInfo else {
            return Empty().eraseToAnyPublisher()
        }
        
        let existingToken = exposureInfoProvider.exposureInfo?.approvalToken
        return getCircuitBreakerResolution(for: .exposureNotification(riskInfo), existingToken: existingToken)
            .handleEvents(receiveOutput: { [weak self] resoltion in
                guard let self = self else { return }
                if resoltion == .proceed {
                    self.handleContactCase(riskInfo)
                } else if self.showDontWorryNotificationIfNeeded {
                    self.handleDontWorryNotification()
                }
                
                self.showDontWorryNotificationIfNeeded = false
                
                switch resoltion {
                case .proceed, .ignore:
                    self.exposureInfoProvider.exposureInfo = nil
                case .askAgain(let token):
                    self.exposureInfoProvider.exposureInfo?.approvalToken = token
                }
            })
            .catch { _ -> Empty<Resolution, Never> in
                if self.showDontWorryNotificationIfNeeded {
                    self.handleDontWorryNotification()
                }
                self.showDontWorryNotificationIfNeeded = false
                return Empty<Resolution, Never>()
            }
            .map { _ in }
            .eraseToAnyPublisher()
    }
    
    func processRiskyVenueApproval() -> AnyPublisher<Void, Never> {
        let venueIdsPendingApproval = Set(
            riskyCheckinsProvider.riskyCheckIns
                .filter { $0.isRisky && $0.circuitBreakerApproval == .pending }
                .map { $0.venueId }
        )
        
        return Publishers.Sequence(sequence: venueIdsPendingApproval)
            .flatMap(processRiskyVenueApproval(with:))
            .eraseToAnyPublisher()
    }
    
    private func processRiskyVenueApproval(with venueId: String) -> AnyPublisher<Void, Never> {
        let token = riskyCheckinsProvider.riskApprovalTokens[venueId]
        return getCircuitBreakerResolution(for: .riskyVenue(venueId), existingToken: token)
            .handleEvents(receiveOutput: { [weak self] resoltion in
                guard let self = self else { return }
                switch resoltion {
                case .proceed:
                    self.riskyCheckinsProvider.riskApprovalTokens[venueId] = nil
                    self.riskyCheckinsProvider.set(.yes, for: venueId)
                case .ignore:
                    self.riskyCheckinsProvider.riskApprovalTokens[venueId] = nil
                    self.riskyCheckinsProvider.set(.no, for: venueId)
                case .askAgain(let token):
                    self.riskyCheckinsProvider.riskApprovalTokens[venueId] = token
                }
            })
            .catch { _ in Empty<Resolution, Never>() }
            .map { _ in }
            .eraseToAnyPublisher()
    }
    
    private func getCircuitBreakerResolution(for type: CircuitBreakerType, existingToken: CircuitBreakerApprovalToken?) -> AnyPublisher<Resolution, Error> {
        if let approvalToken = existingToken {
            return getCircuitBreakerPermission(for: type, with: approvalToken)
        }
        
        return client.fetchApproval(for: type)
            .map { response in
                switch response.approval {
                case .yes:
                    return .proceed
                case .no:
                    return .ignore
                case .pending:
                    return .askAgain(response.approvalToken)
                }
            }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
    
    private func getCircuitBreakerPermission(for type: CircuitBreakerType, with approvalToken: CircuitBreakingClient.ApprovalToken) -> AnyPublisher<Resolution, Error> {
        client.fetchResolution(for: type, with: approvalToken)
            .map { response in
                switch response.approval {
                case .yes:
                    return .proceed
                case .no:
                    return .ignore
                case .pending:
                    return .askAgain(approvalToken)
                }
            }
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
}
