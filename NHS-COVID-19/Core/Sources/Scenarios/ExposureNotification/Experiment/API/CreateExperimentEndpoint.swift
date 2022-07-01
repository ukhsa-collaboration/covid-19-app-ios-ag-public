//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct CreateExperimentEndpoint: HTTPEndpoint {

    var team: String

    func request(for input: Experiment.Create) throws -> HTTPRequest {
        let encoding = JSONEncoder()
        encoding.dateEncodingStrategy = .iso8601
        let body = try encoding.encode(input)
        return .post("/team/\(team)/experiment", body: .json(body))
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
