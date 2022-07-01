//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

extension URLRequest {

    var headers: HTTPHeaders {
        HTTPHeaders(fields: allHTTPHeaderFields ?? [:])
    }

}
