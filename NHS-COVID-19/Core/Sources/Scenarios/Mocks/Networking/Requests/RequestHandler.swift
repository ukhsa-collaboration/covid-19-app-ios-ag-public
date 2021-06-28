//
// Copyright © 2021 DHSC. All rights reserved.
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
        return paths.contains { path.hasPrefix($0) }
    }
    
    func value<T>(named name: String, content: T?) -> String {
        if let content = content {
            if content is String {
                return """
                \"\(name)\": "\(content)"
                """
            } else {
                return """
                \"\(name)\": \(content)
                """
            }
        } else {
            return """
            \"\(name)\": null
            """
        }
    }
    
}
