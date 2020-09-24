//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

extension TimeZone {
    public static let utc = TimeZone(identifier: "UTC")!
}

extension Calendar {
    public static let gregorian = Calendar(identifier: .gregorian)
    public static let utc: Calendar = {
        var calendar = Calendar.gregorian
        calendar.timeZone = .utc
        return calendar
    }()
}
