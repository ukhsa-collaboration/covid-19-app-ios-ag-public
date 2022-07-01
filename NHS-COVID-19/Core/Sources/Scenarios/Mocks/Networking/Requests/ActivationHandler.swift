//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct ActivationHandler: RequestHandler {
    var paths = ["/activation/request"]

    var response: Result<HTTPResponse, HTTPRequestError> {
        Result.success(.ok(with: .empty))
    }
}
