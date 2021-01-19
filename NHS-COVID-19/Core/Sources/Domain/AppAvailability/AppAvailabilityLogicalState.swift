//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct AppAvailabilityMetadata: Equatable {
    let titles: LocaleString
    let descriptions: LocaleString
    let state: AppAvailabilityLogicalState
}

enum AppAvailabilityLogicalState: Equatable {
    enum UnavailabilityReason: Equatable {
        case iOSTooOld
        case appTooOld(updateAvailable: Bool)
    }
    
    enum RecommendationReason: Equatable {
        case iOSOlderThanRecommended(version: Version)
        case appOlderThanRecommended(version: Version)
    }
    
    case available
    case recommending(reason: RecommendationReason)
    case unavailable(reason: UnavailabilityReason)
}

extension AppAvailabilityMetadata {
    
    init(
        availability: AppAvailability,
        iOSVersion: Version,
        appVersion: Version,
        latestAppVersion: Version?
    ) {
        if iOSVersion < availability.iOSVersion.minimumSupported {
            state = .unavailable(reason: .iOSTooOld)
            titles = [:]
            descriptions = availability.iOSVersion.descriptions
        } else if appVersion < availability.appVersion.minimumSupported {
            let updateAvailable = (latestAppVersion ?? Version(major: 0)) >= availability.appVersion.minimumSupported
            state = .unavailable(reason: .appTooOld(updateAvailable: updateAvailable))
            titles = [:]
            descriptions = availability.appVersion.descriptions
        } else if iOSVersion < availability.recommendediOSVersion.minimumRecommended {
            state = .recommending(reason: .iOSOlderThanRecommended(version: availability.recommendediOSVersion.minimumRecommended))
            titles = availability.recommendediOSVersion.titles
            descriptions = availability.recommendediOSVersion.descriptions
        } else if appVersion < availability.recommendedAppVersion.minimumRecommended,
            (latestAppVersion ?? Version(major: 0)) >= availability.recommendedAppVersion.minimumRecommended {
            state = .recommending(reason: .appOlderThanRecommended(version: availability.recommendedAppVersion.minimumRecommended))
            titles = availability.recommendedAppVersion.titles
            descriptions = availability.recommendedAppVersion.descriptions
        } else {
            state = .available
            titles = [:]
            descriptions = [:]
        }
    }
}
