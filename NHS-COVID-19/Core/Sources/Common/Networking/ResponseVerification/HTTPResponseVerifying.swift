//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

public protocol HTTPResponseVerifying {
    func prepare(_ request: HTTPRequest) -> HTTPRequest

    func canAccept(_ response: HTTPResponse, for request: HTTPRequest) -> Bool
}

extension HTTPResponseVerifying {

    public func verify(_ response: HTTPResponse, for request: HTTPRequest) -> Result<HTTPResponse, HTTPRequestError> {
        if canAccept(response, for: request) {
            return .success(response)
        } else {
            return .failure(.networkFailure(underlyingError: URLError(.secureConnectionFailed)))
        }
    }

}
