//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation
import Logging

struct EmptyEndpoint: HTTPEndpoint {
    
    private static let logger = Logger(label: "empty-submission")
    
    func request(for input: TrafficObfuscator) throws -> HTTPRequest {
        Self.logger.info("Empty-submission (source: \(input))")
        
        let payload = ObfuscationPlayload(source: input)
        
        let encoder = JSONEncoder()
        let data = try encoder.encode(payload)
        
        return .post("/submission/empty-submission", body: .json(data))
    }
    
    func parse(_ response: HTTPResponse) throws {}
}

private struct ObfuscationPlayload: Encodable {
    var source: TrafficObfuscator
}
