//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct CircuitBreakerResolutionEndpoint: HTTPEndpoint {
    private let type: CircuitBreakerType

    init(type: CircuitBreakerType) {
        self.type = type
    }

    func request(for input: CircuitBreakerApprovalToken) throws -> HTTPRequest {
        .get("/circuit-breaker/\(type.endpointName)/resolution/\(input.value)")
    }

    func parse(_ response: HTTPResponse) throws -> Response {
        try Response.parse(response)
    }
}

extension CircuitBreakerResolutionEndpoint {
    struct Response: Decodable, Equatable {
        var approval: CircuitBreakerApproval

        static func parse(_ response: HTTPResponse) throws -> Self {
            let jsonDecoder = JSONDecoder()
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
            return try jsonDecoder.decode(Self.self, from: response.body.content)
        }
    }
}
