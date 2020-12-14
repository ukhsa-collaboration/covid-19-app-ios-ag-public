//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct GetExperimentEndpoint: HTTPEndpoint {
    
    var team: String
    var experimentId: String?
    
    func request(for input: Void) throws -> HTTPRequest {
        let experimentPath = experimentId ?? "latest"
        return .get("/team/\(team)/experiment/\(experimentPath)")
    }
    
    func parse(_ response: HTTPResponse) throws -> Experiment {
        let decoder = JSONDecoder()
        let formatter1 = ISO8601DateFormatter()
        let formatter2 = ISO8601DateFormatter()
        formatter2.formatOptions = .withFractionalSeconds
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            guard let date = formatter1.date(from: string) ?? formatter2.date(from: string) else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: container.codingPath,
                        debugDescription: "Invalid date"
                    )
                )
            }
            return date
        }
        return try decoder.decode(Experiment.self, from: response.body.content)
    }
    
}

struct GetExperimentEndpointV2: HTTPEndpoint {
    
    var team: String
    var experimentId: String?
    
    func request(for input: Void) throws -> HTTPRequest {
        let experimentPath = experimentId ?? "latest"
        return .get("/team/\(team)/experiment/\(experimentPath)")
    }
    
    func parse(_ response: HTTPResponse) throws -> Experiment.ExperimentV2 {
        let decoder = JSONDecoder()
        let formatter1 = ISO8601DateFormatter()
        let formatter2 = ISO8601DateFormatter()
        formatter2.formatOptions = .withFractionalSeconds
        decoder.dateDecodingStrategy = .custom { decoder in
            let container = try decoder.singleValueContainer()
            let string = try container.decode(String.self)
            guard let date = formatter1.date(from: string) ?? formatter2.date(from: string) else {
                throw DecodingError.dataCorrupted(
                    DecodingError.Context(
                        codingPath: container.codingPath,
                        debugDescription: "Invalid date"
                    )
                )
            }
            return date
        }
        return try decoder.decode(Experiment.ExperimentV2.self, from: response.body.content)
    }
    
}
