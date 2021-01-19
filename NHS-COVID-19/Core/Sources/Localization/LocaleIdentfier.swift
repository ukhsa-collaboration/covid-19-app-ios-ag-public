//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

struct LocaleIdentifier {
    var rawValue: String
    
    var canonicalValue: String {
        rawValue.lowercased().replacingOccurrences(of: "_", with: "-")
    }
    
    var languageCode: String {
        String(canonicalValue.split(separator: "-").first ?? "")
    }
    
    init(rawValue: String) {
        self.rawValue = rawValue
    }
}
