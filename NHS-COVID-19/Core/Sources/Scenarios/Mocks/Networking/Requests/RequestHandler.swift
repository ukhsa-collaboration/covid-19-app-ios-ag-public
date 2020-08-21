//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

protocol RequestHandler {
    var paths: [String] { get }
    var response: Result<HTTPResponse, HTTPRequestError> { get }
    func hasResponse(for path: String) -> Bool
}

extension RequestHandler {
    func hasResponse(for path: String) -> Bool {
        return paths.contains { $0.hasPrefix(path) }
    }
}
