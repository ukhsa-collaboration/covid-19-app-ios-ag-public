//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct SendResultsEndpoint: HTTPEndpoint {
    
    var team: String
    var experimentId: String
    var deviceName: String
    
    func request(for input: Experiment.DetectionResults) throws -> HTTPRequest {
        let encoder = JSONEncoder()
        encoder.dateEncodingStrategy = .iso8601
        let body = try encoder.encode(input)
        return .post("/team/\(team)/experiment/\(experimentId)/result/\(deviceName)", body: .json(body))
    }
    
    func parse(_ response: HTTPResponse) throws {}
    
}
