//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation

struct EmptyHandler: RequestHandler {
    var paths = ["/submission/empty-submission-v2"]

    var response: Result<HTTPResponse, HTTPRequestError> {
        return Result.success(.ok(with: .empty))
    }
}
