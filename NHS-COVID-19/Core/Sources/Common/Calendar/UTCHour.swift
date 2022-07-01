//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation

/// An hour which is valid in the UTC Calendar
///
/// A `UTCHour` uses a Gregorian calendar and UTC `TimeZone` to ensure validity
public struct UTCHour: Codable, Equatable, Hashable {

    public let day: GregorianDay
    public let hour: Int
    public let minutes: Int

    public var dateComponents: DateComponents {
        mutating(day.dateComponents) {
            $0.calendar = .utc
            $0.hour = hour
            $0.minute = minutes
        }
    }

    public var date: Date {
        dateComponents.date!
    }

    public init(day: GregorianDay, hour: Int, minutes: Int) {
        self.day = day
        self.hour = hour
        self.minutes = minutes
        Thread.assert(dateComponents.isValidDate)
    }

    public init(year: Int, month: Int, day: Int, hour: Int, minutes: Int = 0) {
        self.init(day: GregorianDay(year: year, month: month, day: day), hour: hour, minutes: minutes)
    }

    public init(dateComponents: DateComponents) {
        self.init(day: GregorianDay(dateComponents: dateComponents), hour: dateComponents.hour!, minutes: dateComponents.minute ?? 0)
    }

    public init(containing date: Date) {
        let dateComponents = Calendar.utc.dateComponents([.year, .month, .day, .hour, .minute], from: date)
        self.init(dateComponents: dateComponents)
    }

    public init(roundedDownToQuarter date: Date) {
        let minuteGranularity = 15
        let dateComponents = mutating(Calendar.utc.dateComponents([.year, .month, .day, .hour, .minute], from: date)) {
            $0.minute! -= ($0.minute! % minuteGranularity)
        }
        self.init(dateComponents: dateComponents)
    }

    public init(roundedUpToQuarter date: Date) {
        self.init(roundedDownToQuarter: date.advanced(by: 15 * 60))
    }
}

extension UTCHour: Comparable {
    public static func < (lhs: UTCHour, rhs: UTCHour) -> Bool {
        lhs.date < rhs.date
    }

}

extension UTCHour {
    public func isLaterThanOrEqualTo(hours: Int, after other: UTCHour) -> Bool {
        date.timeIntervalSince(other.date) >= TimeInterval(60 * 60 * hours)
    }
}
