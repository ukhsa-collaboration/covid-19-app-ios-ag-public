//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

/// A day which is valid in the Gregorian Calendar
///
/// A `GregorianDay` is defined independantly of any `TimeZone`, so one should be provided when converting to and from a `Date`
public struct GregorianDay: Equatable, Strideable, Codable, Hashable {
    public let year: Int
    public let month: Int
    public let day: Int
    
    public var dateComponents: DateComponents {
        DateComponents(calendar: .gregorian, year: year, month: month, day: day)
    }
    
    public init(year: Int, month: Int, day: Int) {
        self.year = year
        self.month = month
        self.day = day
        Thread.assert(dateComponents.isValidDate)
    }
    
    public func distance(to other: GregorianDay) -> Int {
        let calendar = Calendar.gregorian
        return calendar.dateComponents(
            [.day],
            from: startDate(in: calendar.timeZone),
            to: other.startDate(in: calendar.timeZone)
        ).day!
    }
    
    public func advanced(by days: Int) -> GregorianDay {
        let calendar = Calendar.gregorian
        let date = calendar.date(from: dateComponents)!
        let newDate = calendar.date(byAdding: DateComponents(day: days), to: date)!
        return GregorianDay(date: newDate, timeZone: calendar.timeZone)
    }
    
}

extension GregorianDay: Comparable {
    public func startDate(in timeZone: TimeZone) -> Date {
        var dateComponents = self.dateComponents
        dateComponents.calendar?.timeZone = timeZone
        return dateComponents.date!
    }
    
    public static func < (lhs: GregorianDay, rhs: GregorianDay) -> Bool {
        lhs.startDate(in: .current) < rhs.startDate(in: .current)
    }
}

extension GregorianDay {
    public init(dateComponents: DateComponents) {
        self.init(year: dateComponents.year!, month: dateComponents.month!, day: dateComponents.day!)
    }
    
    public init(date: Date, timeZone: TimeZone) {
        var calendar = Calendar.gregorian
        calendar.timeZone = timeZone
        self.init(dateComponents: calendar.dateComponents([.year, .month, .day], from: date))
    }
    
    public static var today: GregorianDay {
        GregorianDay(date: Date(), timeZone: .current)
    }
}
