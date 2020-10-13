//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import TestSupport
@testable import Domain

class MockCircuitBreakerClient: CircuitBreakingClient {
    var approvalResponse: ApprovalEndpoint.Response?
    var resolutionResponse: ResolutionEndpoint.Response?
    var approvalType: CircuitBreakerType?
    var resolutionRequest: ApprovalToken?
    var shouldShowError = false
    
    func fetchApproval(for type: CircuitBreakerType) -> AnyPublisher<ApprovalEndpoint.Response, Error> {
        if shouldShowError {
            return Result.failure(TestError("")).publisher.eraseToAnyPublisher()
        } else {
            approvalType = type
            return Optional.Publisher(approvalResponse).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
    }
    
    func fetchResolution(for type: CircuitBreakerType, with approvalToken: ApprovalToken) -> AnyPublisher<ResolutionEndpoint.Response, Error> {
        if shouldShowError {
            return Result.failure(TestError("")).publisher.eraseToAnyPublisher()
        } else {
            resolutionRequest = approvalToken
            return Optional.Publisher(resolutionResponse).setFailureType(to: Error.self).eraseToAnyPublisher()
        }
    }
}
