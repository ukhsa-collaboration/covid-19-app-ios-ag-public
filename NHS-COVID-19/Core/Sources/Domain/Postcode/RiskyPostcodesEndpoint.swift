//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct RiskyPostcodesEndpoint: HTTPEndpoint {
    
    func request(for input: Void) throws -> HTTPRequest {
        .get("/distribution/risky-post-districts")
    }
    
    func parse(_ response: HTTPResponse) throws -> [String: PostcodeRisk] {
        try JSONDecoder().decode(Payload.self, from: response.body.content).postDistricts
    }
    
}

private struct Payload: Codable {
    var postDistricts: [String: PostcodeRisk]
}
