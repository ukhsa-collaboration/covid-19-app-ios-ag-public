//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common

protocol CircuitBreakingClient {
    typealias ApprovalEndpoint = CircuitBreakerApprovalEndpoint
    typealias ResolutionEndpoint = CircuitBreakerResolutionEndpoint
    typealias ApprovalToken = CircuitBreakerApprovalToken
    typealias emptyEndpoint = EmptyEndpoint
    
    func fetchApproval(for type: CircuitBreakerType) -> AnyPublisher<ApprovalEndpoint.Response, Error>
    func fetchResolution(
        for type: CircuitBreakerType,
        with approvalToken: ApprovalToken
    ) -> AnyPublisher<ResolutionEndpoint.Response, Error>
    func sendObfuscatedTraffic(for type: TrafficObfuscator) -> AnyPublisher<Void, Never>
}

struct CircuitBreakerClient: CircuitBreakingClient {
    var httpClient: HTTPClient
    
    func fetchApproval(for type: CircuitBreakerType) -> AnyPublisher<Self.ApprovalEndpoint.Response, Error> {
        httpClient.fetch(ApprovalEndpoint(), with: type).mapError { $0 as Error }.eraseToAnyPublisher()
    }
    
    func fetchResolution(
        for type: CircuitBreakerType,
        with approvalToken: ApprovalToken
    ) -> AnyPublisher<Self.ResolutionEndpoint.Response, Error> {
        httpClient.fetch(ResolutionEndpoint(type: type), with: approvalToken)
            .mapError { $0 as Error }
            .eraseToAnyPublisher()
    }
    
    func sendObfuscatedTraffic(for type: TrafficObfuscator) -> AnyPublisher<Void, Never> {
        httpClient.fetch(emptyEndpoint(), with: type).replaceError(with: ()).eraseToAnyPublisher()
    }
}
