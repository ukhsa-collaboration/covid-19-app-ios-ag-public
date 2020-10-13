//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct RiskyPostcodesEndpointV1: HTTPEndpoint {
    
    func request(for input: Void) throws -> HTTPRequest {
        .get("/distribution/risky-post-districts")
    }
    
    func parse(_ response: HTTPResponse) throws -> [Postcode: PostcodeRisk] {
        let districts = try JSONDecoder().decode(Payload.self, from: response.body.content).postDistricts
        return Dictionary(districts.map { (Postcode($0), $1) }, uniquingKeysWith: { $1 })
    }
    
}

private struct Payload: Codable {
    var postDistricts: [String: PostcodeRisk]
}
