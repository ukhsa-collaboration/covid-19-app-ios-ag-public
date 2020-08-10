//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

extension HTTPRequest {
    public struct Body: Equatable {
        public let content: Data
        public let type: String
        public init(content: Data, type: String) {
            self.content = content
            self.type = type
        }
    }
}

extension HTTPRequest.Body {
    
    public static func plain(_ data: Data) -> HTTPRequest.Body {
        HTTPRequest.Body(
            content: data,
            type: "text/plain"
        )
    }
    
    public static func plain(_ text: String) -> HTTPRequest.Body {
        .plain(text.data(using: .utf8)!)
    }
    
    public static func json(_ data: Data) -> HTTPRequest.Body {
        HTTPRequest.Body(
            content: data,
            type: "application/json"
        )
    }
    
    public static func json(_ string: String) -> HTTPRequest.Body {
        json(string.data(using: .utf8)!)
    }
}
