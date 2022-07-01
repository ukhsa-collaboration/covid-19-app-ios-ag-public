//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct DiagnosisKeysHandler: RequestHandler {
    var paths = ["/submission/diagnosis-keys"]

    var response: Result<HTTPResponse, HTTPRequestError> {
        Result.success(.ok(with: .empty))
    }
}
