//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct CircuitBreakerApprovalEndpoint: HTTPEndpoint {
    
    func request(for type: CircuitBreakerType) throws -> HTTPRequest {
        let encoder = JSONEncoder()
        let data: Data
        switch type {
        case .exposureNotification(let riskInfo):
            data = try encoder.encode(ExposureNotificationRequstPayload(
                maximumRiskScore: riskInfo.riskScore,
                daysSinceLastExposure: riskInfo.day.distance(to: .today),
                matchedKeyCount: 1
            ))
        case .riskyVenue(let venueId):
            data = try encoder.encode(VenueRequstPayload(venueId: venueId))
        }
        return .post("/circuit-breaker/\(type.endpointName)/request", body: .json(data))
    }
    
    func parse(_ response: HTTPResponse) throws -> Response {
        try Response.parse(response)
    }
}

extension CircuitBreakerApprovalEndpoint {
    struct Response: Decodable, Equatable {
        var approvalToken: CircuitBreakerApprovalToken
        var approval: CircuitBreakerApproval
        
        static func parse(_ response: HTTPResponse) throws -> Self {
            let jsonDecoder = JSONDecoder()
            jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
            return try jsonDecoder.decode(Self.self, from: response.body.content)
        }
    }
}

private struct VenueRequstPayload: Codable {
    var venueId: String
}

private struct ExposureNotificationRequstPayload: Codable {
    var maximumRiskScore: Double
    var daysSinceLastExposure: Int
    var matchedKeyCount: Int
}
