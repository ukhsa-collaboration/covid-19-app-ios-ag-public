//
// Copyright © 2022 DHSC. All rights reserved.
//

import Common

public struct SelectedDay {
    public let day: GregorianDay
    public var doNotRemember: Bool

    public init(day: GregorianDay, doNotRemember: Bool = false) {
        self.day = day
        self.doNotRemember = doNotRemember
    }
}
