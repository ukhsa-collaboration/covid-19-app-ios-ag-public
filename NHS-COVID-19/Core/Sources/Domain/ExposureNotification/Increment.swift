//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common

enum Increment {
    case twoHourly(Day, TwoHour)
    case daily(Day)
}

extension Increment {
    typealias Day = GregorianDay
    struct TwoHour {
        var value: Int

        public init(value: Int) {
            self.value = value
        }
    }
}

extension Increment {
    static let IdentifierPrefix = "increment_"
    var identifier: String {
        switch self {
        case .twoHourly:
            return "\(Self.IdentifierPrefix)twoHourly_\(parse())"
        case .daily:
            return "\(Self.IdentifierPrefix)daily_\(parse())"
        }
    }
}
