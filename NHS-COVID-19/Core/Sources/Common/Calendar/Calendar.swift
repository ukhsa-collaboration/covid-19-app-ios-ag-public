//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

extension Calendar {
    public static let gregorian = Calendar(identifier: .gregorian)
    public static let utc: Calendar = {
        var calendar = Calendar.gregorian
        calendar.timeZone = TimeZone(identifier: "UTC")!
        return calendar
    }()
}
