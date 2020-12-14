//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct IsolationPaymentUpdateHandler: RequestHandler {
    var paths = ["/isolation-payment/ipc-token/update"]
    var response: Result<HTTPResponse, HTTPRequestError> {
        let json = """
        {
            "websiteUrlWithQuery": "https://example.com"
        }
        """
        return Result.success(.ok(with: .json(json)))
    }
}
