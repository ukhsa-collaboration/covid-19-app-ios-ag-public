//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Foundation

public protocol HTTPEndpoint {
    associatedtype Input
    associatedtype Output
    func request(for input: Input) throws -> HTTPRequest
    func parse(_ response: HTTPResponse) throws -> Output
}

/// Error returned when performing a request against an `HTTPEndpoint`
public enum NetworkRequestError: Error {
    /// The endpoint could not create an `HTTPRequest` from the `Input`.
    case badInput(underlyingError: Error)

    /// The client rejected the `HTTPRequest`
    case rejectedRequest(underlyingError: Error)

    /// Encountered an error making the requests
    case networkFailure(underlyingError: URLError)

    /// The services returned an HTTP error (Status code is not 2xx)
    case httpError(response: HTTPResponse)

    /// Could not parse the HTTP response
    case badResponse(underlyingError: Error)
}

extension HTTPClient {

    public func fetch<E: HTTPEndpoint>(_ endpoint: E) -> AnyPublisher<E.Output, NetworkRequestError> where E.Input == Void {
        fetch(endpoint, with: ())
    }

    public func fetch<E: HTTPEndpoint>(_ endpoint: E, with input: E.Input) -> AnyPublisher<E.Output, NetworkRequestError> {
        do {
            let request = try endpoint.request(for: input)
            return perform(request)
                .mapError { error in
                    switch error {
                    case .rejectedRequest(let underlyingError):
                        return .rejectedRequest(underlyingError: underlyingError)
                    case .networkFailure(let underlyingError):
                        return .networkFailure(underlyingError: underlyingError)
                    }
                }
                .flatMap { response -> AnyPublisher<HTTPResponse, NetworkRequestError> in
                    switch response.statusCode {
                    case 200 ..< 300:
                        return Just(response)
                            .setFailureType(to: NetworkRequestError.self)
                            .eraseToAnyPublisher()
                    default:
                        return Fail(error: NetworkRequestError.httpError(response: response))
                            .eraseToAnyPublisher()
                    }
                }
                .flatMap { response in
                    Result { try endpoint.parse(response) }
                        .mapError { NetworkRequestError.badResponse(underlyingError: $0) }
                        .publisher
                }
                .eraseToAnyPublisher()
        } catch {
            return Fail(error: .badInput(underlyingError: error))
                .eraseToAnyPublisher()
        }
    }

}
