//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

public extension HTTPRequest {
    
    func withCanonicalJSONBody() -> HTTPRequest {
        guard let body = body else {
            return self
        }
        
        let normalizedContent = body.content.normalizingJSON()
        
        return HTTPRequest(
            method: method,
            path: path,
            body: Body(content: normalizedContent, type: body.type),
            fragment: fragment,
            queryParameters: queryParameters,
            headers: headers
        )
    }
    
}
