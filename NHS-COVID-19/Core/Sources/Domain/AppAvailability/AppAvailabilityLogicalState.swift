//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

enum AppAvailabilityLogicalState: Equatable {
    enum UnavailabilityReason: Equatable {
        case iOSTooOld(descriptions: [Locale: String])
        case appTooOld(updateAvailable: Bool, descriptions: [Locale: String])
    }
    
    case available
    case unavailable(reason: UnavailabilityReason)
}

extension AppAvailabilityLogicalState {
    
    init(
        availability: AppAvailability,
        iOSVersion: Version,
        appVersion: Version,
        latestAppVersion: Version?
    ) {
        if iOSVersion < availability.iOSVersion.minimumSupported {
            self = .unavailable(reason: .iOSTooOld(descriptions: availability.iOSVersion.descriptions))
        } else if appVersion < availability.appVersion.minimumSupported {
            let updateAvailable = (latestAppVersion ?? Version(major: 0)) >= availability.appVersion.minimumSupported
            self = .unavailable(reason:
                .appTooOld(updateAvailable: updateAvailable, descriptions: availability.appVersion.descriptions)
            )
        } else {
            self = .available
        }
    }
    
}
