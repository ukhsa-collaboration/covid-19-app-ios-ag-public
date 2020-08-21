//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct CircuitBreakerVenueHandler: RequestHandler {
    var paths = ["/circuit-breaker/exposure-notification/request"]
    
    var response: Result<HTTPResponse, HTTPRequestError> {
        let response = HTTPResponse.ok(with: .json("""
        {
        "approval_token": "\(UUID().uuidString)",
        "approval": "yes"
        }
        """))
        return Result.success(response)
    }
}
