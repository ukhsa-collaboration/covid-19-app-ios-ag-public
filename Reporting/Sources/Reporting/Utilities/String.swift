//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

extension String {

    func matches(_ pattern: String) -> Bool {
        range(of: "^\(pattern)$", options: .regularExpression, range: nil, locale: nil) != nil
    }

    var trimmed: String {
        trimmingCharacters(in: .whitespacesAndNewlines)
    }
}
