//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Foundation
import Logging

public protocol URLSessionProtocol {
    func dataTaskPublisher(for request: URLRequest) -> URLSession.DataTaskPublisher
}

public protocol URLRequestProviding {
    func urlRequest(from request: HTTPRequest) throws -> URLRequest
}

extension URLSession: URLSessionProtocol {}

public final class URLSessionHTTPClient: HTTPClient {
    
    private static let logger = Logger(label: "HTTPClient")
    
    private let remote: URLRequestProviding
    private let session: URLSessionProtocol
    
    public init(remote: URLRequestProviding, session: URLSessionProtocol = URLSession.shared) {
        self.remote = remote
        self.session = session
    }
    
    public func perform(_ request: HTTPRequest) -> AnyPublisher<HTTPResponse, HTTPRequestError> {
        let id = UUID()
        Self.logger.debug("starting request \(id)", metadata: .describing(request))
        return Just(request)
            .tryMap { try self.remote.urlRequest(from: $0) }
            .mapError(HTTPRequestError.rejectedRequest(underlyingError:))
            .flatMap {
                self.session.dataTaskPublisher(for: $0)
                    .mapError(HTTPRequestError.networkFailure(underlyingError:))
            }
            .map { HTTPResponse(httpUrlResponse: $1 as! HTTPURLResponse, bodyContent: $0) }
            .handleEvents().log(into: Self.logger, level: .debug, "ending request \(id) - \(request.path)")
            .eraseToAnyPublisher()
    }
    
}
