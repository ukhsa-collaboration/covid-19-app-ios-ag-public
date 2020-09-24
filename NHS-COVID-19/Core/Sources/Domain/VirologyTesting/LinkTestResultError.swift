//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common

public enum LinkTestResultError: Error {
    case invalidCode
    case noInternet
    case unknownError
    
    private static let codeNotValid = 404
    private static let codeMalformed = 400
    
    init(_ networkError: NetworkRequestError) {
        switch networkError {
        case .networkFailure(let underlyingError):
            if underlyingError.code == .networkConnectionLost || underlyingError.code == .notConnectedToInternet {
                self = .noInternet
            } else {
                self = .unknownError
            }
        case .httpError(let response):
            if response.statusCode == Self.codeNotValid || response.statusCode == Self.codeMalformed {
                self = .invalidCode
            } else {
                self = .unknownError
            }
        default:
            self = .unknownError
        }
    }
}
