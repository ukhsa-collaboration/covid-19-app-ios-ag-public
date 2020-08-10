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
