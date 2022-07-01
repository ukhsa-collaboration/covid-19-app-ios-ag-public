//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

public struct DayDuration: Comparable, Codable, Equatable, ExpressibleByIntegerLiteral {

    public var days: Int

    public static func < (lhs: DayDuration, rhs: DayDuration) -> Bool {
        lhs.days < rhs.days
    }

    public init(integerLiteral value: Int) {
        days = value
    }

    public init(_ value: Int) {
        days = value
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        days = try container.decode(Int.self)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(days)
    }
}

public func + (lhs: GregorianDay, rhs: DayDuration) -> GregorianDay {
    lhs.advanced(by: rhs.days)
}

public func - (lhs: GregorianDay, rhs: DayDuration) -> GregorianDay {
    lhs + DayDuration(-rhs.days)
}
