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
        
        return .get("/submission/empty-submission-v2")
    }
    
    func parse(_ response: HTTPResponse) throws {}
}
