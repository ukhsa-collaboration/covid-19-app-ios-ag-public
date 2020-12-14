//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common

public class MockHTTPClient: HTTPClient {
    @Published
    public var lastRequest: HTTPRequest?
    public var response: Result<HTTPResponse, HTTPRequestError>?
    private var responses: [String:Result<HTTPResponse, HTTPRequestError>] = [:]
    
    public init() {}
    
    public func perform(_ request: HTTPRequest) -> AnyPublisher<HTTPResponse, HTTPRequestError> {
        lastRequest = request
        return Optional.Publisher(response ?? responses[request.path])
            .setFailureType(to: HTTPRequestError.self)
            .flatMap { $0.publisher }
            .eraseToAnyPublisher()
    }
    
    public func response(for path: String, response: Result<HTTPResponse, HTTPRequestError>) {
        responses[path] = response
    }
    
    public func reset() {
        responses = [:]
        response = nil
    }
}
