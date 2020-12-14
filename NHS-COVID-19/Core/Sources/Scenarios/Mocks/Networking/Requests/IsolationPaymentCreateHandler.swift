//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct IsolationPaymentCreateHandler: RequestHandler {
    var paths = ["/isolation-payment/ipc-token/create"]
    
    var response: Result<HTTPResponse, HTTPRequestError> {
        let ipcTokenString = UUID().uuidString
        let json = """
        {
            "ipcToken": "\(ipcTokenString)",
            "isEnabled": true
        }
        """
        return Result.success(.ok(with: .json(json)))
    }
}
