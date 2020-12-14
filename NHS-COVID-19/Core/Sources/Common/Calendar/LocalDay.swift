//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import UIKit

/// This represents a day with a specific time zone.
public struct LocalDay: Equatable, Hashable {
    public var gregorianDay: GregorianDay
    public var timeZone: TimeZone
    
    public init(gregorianDay: GregorianDay, timeZone: TimeZone) {
        self.gregorianDay = gregorianDay
        self.timeZone = timeZone
    }
    
    public init(year: Int, month: Int, day: Int, timeZone: TimeZone) {
        self.init(
            gregorianDay: GregorianDay(year: year, month: month, day: day),
            timeZone: timeZone
        )
    }
    
    public static var today: LocalDay {
        LocalDay(gregorianDay: .today, timeZone: .current)
    }
    
    public func advanced(by days: Int) -> LocalDay {
        mutating(self) {
            $0.gregorianDay = $0.gregorianDay.advanced(by: days)
        }
    }
}

extension LocalDay {
    
    /// Number of days remainin until the day containing `Date`.
    ///
    /// For example, if `Date` falls within `Day`, this will return `0`.
    public func daysRemaining(until date: Date) -> Int {
        gregorianDay.distance(to: GregorianDay(date: date, timeZone: timeZone))
    }
    
    public var startOfDay: Date {
        gregorianDay.startDate(in: timeZone)
    }
    
    public init(date: Date, timeZone: TimeZone) {
        let gregorianDay = GregorianDay(date: date, timeZone: timeZone)
        self.init(gregorianDay: gregorianDay, timeZone: timeZone)
    }
    
}
