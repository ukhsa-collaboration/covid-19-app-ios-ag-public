//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct RiskyPostDistrictsHandler: RequestHandler {
    var paths = ["/distribution/risky-post-districts"]
    
    var dataProvider: MockDataProvider
    
    var response: Result<HTTPResponse, HTTPRequestError> {
        let highRiskPostcodes = dataProvider.highRiskPostcodes.components(separatedBy: ",")
            .lazy
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .map { "\"\($0)\": \"H\"" }
            .joined(separator: ",")
        
        let mediumRiskPostcodes = dataProvider.mediumRiskPostcodes.components(separatedBy: ",")
            .lazy
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .map { "\"\($0)\": \"M\"" }
            .joined(separator: ",")
        
        let lowRiskPostcodes = dataProvider.lowRiskPostcodes.components(separatedBy: ",")
            .lazy
            .map { $0.trimmingCharacters(in: .whitespacesAndNewlines) }
            .map { "\"\($0)\": \"L\"" }
            .joined(separator: ",")
        
        let json = #"""
        {
        "postDistricts" : { \#(highRiskPostcodes), \#(mediumRiskPostcodes), \#(lowRiskPostcodes) }
        }
        """#
        return Result.success(.ok(with: .json(json)))
    }
}
