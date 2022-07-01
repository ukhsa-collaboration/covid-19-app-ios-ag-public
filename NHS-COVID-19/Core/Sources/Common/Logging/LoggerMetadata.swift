//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import Logging

extension Logger.Metadata {

    public static func describing(_ value: Any) -> Logger.Metadata {
        ["value": .stringConvertible(DescribedValue(value: value))]
    }

}

public struct DescribedValue: CustomStringConvertible {
    public var value: Any
    public var description: String {
        String(describing: value)
    }
}
