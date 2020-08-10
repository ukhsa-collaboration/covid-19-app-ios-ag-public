//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

struct AppAvailability: Equatable {
    struct VersionRequirement: Equatable {
        var minimumSupported: Version
        var descriptions: [Locale: String]
    }
    
    var iOSVersion: VersionRequirement
    var appVersion: VersionRequirement
}
