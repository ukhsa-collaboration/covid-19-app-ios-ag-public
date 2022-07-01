//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation

struct IsolationModelUndefinedMappingError: Error {

    @available(*, deprecated, message: "Using this error signifies that a test case is not defined yet.")
    init() {}
}

struct IsolationModelAcceptanceError: Error, CustomStringConvertible {
    var description: String
    init(_ description: String) {
        self.description = description
    }

    static let forbidden = IsolationModelAcceptanceError("Case forbidden")
}
