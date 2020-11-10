//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

struct AppAvailability: Equatable {
    struct VersionRequirement: Equatable {
        var minimumSupported: Version
        var descriptions: [Locale: String]
    }
    
    struct RecommendationRequirement: Equatable {
        var minimumRecommended: Version
        var titles: [Locale: String]
        var descriptions: [Locale: String]
    }
    
    var iOSVersion: VersionRequirement
    var recommendediOSVersion: RecommendationRequirement
    var appVersion: VersionRequirement
    var recommendedAppVersion: RecommendationRequirement
}
