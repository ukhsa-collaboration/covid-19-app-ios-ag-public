//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common

public class MockHTTPClient: HTTPClient {
    @Published
    public var lastRequest: HTTPRequest?
    public var requests = [HTTPRequest]()
    public var response: Result<HTTPResponse, HTTPRequestError>?
    private var responses: [String: Result<HTTPResponse, HTTPRequestError>] = [:]
    
    public init() {}
    
    public func perform(_ request: HTTPRequest) -> AnyPublisher<HTTPResponse, HTTPRequestError> {
        lastRequest = request
        requests.append(request)
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
        requests = []
        response = nil
    }
}

extension MockHTTPClient {
    
    func register(_ requestHandler: RequestHandler) {
        for path in requestHandler.paths {
            response(for: path, response: requestHandler.response)
        }
    }
    
}
