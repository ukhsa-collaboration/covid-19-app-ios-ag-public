//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

extension HTTPURLResponse {
    
    var headers: HTTPHeaders {
        HTTPHeaders(
            fields: Dictionary(
                uniqueKeysWithValues: allHeaderFields
                    .map { ($0.key as! String, $0.value as! String) }
            )
        )
    }
    
}
