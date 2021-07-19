//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation

// Note: en-GB and en-gb are not equal
public enum LocaleConfiguration: Equatable {
    case systemPreferred
    case custom(localeIdentifier: String)
    
    public init(
        localeIdentifier: String?,
        supportedLocalizations: [String]
    ) {
        if let localeIdentifier = localeIdentifier, supportedLocalizations.contains(localeIdentifier) {
            self = .custom(localeIdentifier: localeIdentifier)
        } else {
            self = .systemPreferred
        }
    }
}
