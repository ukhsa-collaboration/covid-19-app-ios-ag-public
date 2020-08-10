//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
@testable import Domain

class MockCircuitBreakerClient: CircuitBreakingClient {
    var approvalResponse: ApprovalEndpoint.Response?
    var resolutionResponse: ResolutionEndpoint.Response?
    var approvalType: CircuitBreakerType?
    var resolutionRequest: ApprovalToken?
    
    func fetchApproval(for type: CircuitBreakerType) -> AnyPublisher<ApprovalEndpoint.Response, Error> {
        approvalType = type
        return Optional.Publisher(approvalResponse).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
    
    func fetchResolution(for type: CircuitBreakerType, with approvalToken: ApprovalToken) -> AnyPublisher<ResolutionEndpoint.Response, Error> {
        resolutionRequest = approvalToken
        return Optional.Publisher(resolutionResponse).setFailureType(to: Error.self).eraseToAnyPublisher()
    }
}
