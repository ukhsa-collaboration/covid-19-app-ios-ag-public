//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct AppAvailability: Equatable {
    struct VersionRequirement: Equatable {
        var minimumSupported: Version
        var descriptions: LocaleString
    }
    
    struct RecommendationRequirement: Equatable {
        var minimumRecommended: Version
        var titles: LocaleString
        var descriptions: LocaleString
    }
    
    var iOSVersion: VersionRequirement
    var recommendediOSVersion: RecommendationRequirement
    var appVersion: VersionRequirement
    var recommendedAppVersion: RecommendationRequirement
}
