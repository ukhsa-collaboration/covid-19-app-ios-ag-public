//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct AppAvailabilityEndpoint: HTTPEndpoint {
    
    func request(for input: Void) throws -> HTTPRequest {
        .get("/distribution/availability-ios")
    }
    
    func parse(_ response: HTTPResponse) throws -> AppAvailability {
        let decoder = JSONDecoder()
        let payload = try decoder.decode(Payload.self, from: response.body.content)
        return try AppAvailability(from: payload)
    }
    
}

private struct Payload: Decodable {
    struct Requirement: Decodable {
        var value: String
        var description: [String: String]
    }
    
    var minimumOSVersion: Requirement
    var minimumAppVersion: Requirement
}

private extension AppAvailability {
    
    init(from payload: Payload) throws {
        try self.init(
            iOSVersion: VersionRequirement(from: payload.minimumOSVersion),
            appVersion: VersionRequirement(from: payload.minimumAppVersion)
        )
    }
    
}

private extension AppAvailability.VersionRequirement {
    
    init(from requirement: Payload.Requirement) throws {
        let descriptions = Dictionary(uniqueKeysWithValues: requirement.description.compactMap { key, value in
            (Locale(identifier: key), value)
        })
        
        self.init(minimumSupported: try Version(requirement.value), descriptions: descriptions)
    }
    
}
