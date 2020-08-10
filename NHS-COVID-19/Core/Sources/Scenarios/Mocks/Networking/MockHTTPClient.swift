//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common

public class MockHTTPClient: HTTPClient {
    public var lastRequest: HTTPRequest?
    public var response: Result<HTTPResponse, HTTPRequestError>?
    
    public init() {}
    
    public func perform(_ request: HTTPRequest) -> AnyPublisher<HTTPResponse, HTTPRequestError> {
        lastRequest = request
        return Optional.Publisher(response)
            .setFailureType(to: HTTPRequestError.self)
            .flatMap { $0.publisher }
            .eraseToAnyPublisher()
    }
}
