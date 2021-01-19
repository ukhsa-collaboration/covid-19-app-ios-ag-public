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
        var description: LocaleString
    }
    
    struct RecommendationRequirement: Decodable {
        var value: String
        var title: LocaleString
        var description: LocaleString
    }
    
    var minimumOSVersion: Requirement
    var recommendedOSVersion: RecommendationRequirement?
    var minimumAppVersion: Requirement
    var recommendedAppVersion: RecommendationRequirement?
}

private extension AppAvailability {
    
    init(from payload: Payload) throws {
        try self.init(
            iOSVersion: VersionRequirement(from: payload.minimumOSVersion),
            recommendediOSVersion: payload.recommendedOSVersion == nil ?
                RecommendationRequirement(from: payload.minimumOSVersion) : RecommendationRequirement(from: payload.recommendedOSVersion!),
            appVersion: VersionRequirement(from: payload.minimumAppVersion),
            recommendedAppVersion: payload.recommendedAppVersion == nil ?
                RecommendationRequirement(from: payload.minimumAppVersion) : RecommendationRequirement(from: payload.recommendedAppVersion!)
        )
    }
    
}

private extension AppAvailability.VersionRequirement {
    
    init(from requirement: Payload.Requirement) throws {
        self.init(
            minimumSupported: try Version(requirement.value),
            descriptions: requirement.description
        )
    }
    
}

private extension AppAvailability.RecommendationRequirement {
    #warning("This can be removed when the backend is deployed")
    init(from requirement: Payload.Requirement) throws {
        self.init(
            minimumRecommended: try Version(requirement.value),
            titles: [:],
            descriptions: requirement.description
        )
    }
    
    init(from requirement: Payload.RecommendationRequirement) throws {
        self.init(
            minimumRecommended: try Version(requirement.value),
            titles: requirement.title,
            descriptions: requirement.description
        )
    }
    
}
