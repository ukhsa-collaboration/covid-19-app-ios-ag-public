//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Foundation

public enum HTTPRequestError: Error {
    case rejectedRequest(underlyingError: Error)
    case networkFailure(underlyingError: URLError)
}

public protocol HTTPClient {
    func perform(_ request: HTTPRequest) -> AnyPublisher<HTTPResponse, HTTPRequestError>
}
