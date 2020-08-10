//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct EnrolParticipantEndpoint: HTTPEndpoint {
    
    var team: String
    var experimentId: String
    
    func request(for input: Experiment.Participant) throws -> HTTPRequest {
        let body = try JSONEncoder().encode(input)
        return .post("/team/\(team)/experiment/\(experimentId)/device", body: .json(body))
    }
    
    func parse(_ response: HTTPResponse) throws {}
    
}
