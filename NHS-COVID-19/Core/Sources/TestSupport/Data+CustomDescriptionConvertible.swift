//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

extension Data: CustomDescriptionConvertible {
    public var descriptionObject: Description {
        if let string = String(data: self, encoding: .utf8) {
            return .string(string)
        } else {
            return .string(base64EncodedString())
        }
    }
}
