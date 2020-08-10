//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct AppActivationEndpoint: HTTPEndpoint {
    
    func request(for code: String) throws -> HTTPRequest {
        let data = try JSONEncoder().encode(RequestPayload(activationCode: code))
        return .post("/activation/request", body: .json(data))
    }
    
    func parse(_ response: HTTPResponse) throws {}
    
}

private struct RequestPayload: Codable {
    var activationCode: String
}
