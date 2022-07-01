//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

public struct TestError: Error, CustomStringConvertible {
    public var description: String

    public init(_ description: String) {
        self.description = description
    }
}
