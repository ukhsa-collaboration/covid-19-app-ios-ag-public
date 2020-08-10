//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

extension Increment {
    static func nextIncrement(lastCheckDate: Date, now: Date) -> (increment: Increment, checkDate: Date)? {
        let difference = Calendar.utc.dateComponents([.day, .hour], from: lastCheckDate, to: now)
        
        let period: Period.Type = difference.day! * 24 + difference.hour! > 26 ? Increment.Day.self : Increment.TwoHour.self
        var dateComponents = Calendar.utc.dateComponents([.year, .month, .day, .hour], from: lastCheckDate)
        let endOfPeriod = Int(Double(dateComponents.hour!).rounded(.down, toNearest: Double(period.hours))) + period.hours
        dateComponents.setValue(endOfPeriod, for: .hour)
        
        let checkDate = Calendar.utc.date(from: dateComponents)!
        if checkDate > now { return nil }
        
        let incrementDateComponents = Calendar.utc.dateComponents([.year, .month, .day, .hour], from: checkDate)
        return (period.createIncrement(dateComponents: incrementDateComponents), checkDate)
    }
}

private protocol Period {
    static var hours: Int { get }
    static func createIncrement(dateComponents: DateComponents) -> Increment
}

extension Increment.Day: Period {
    fileprivate static func createIncrement(dateComponents: DateComponents) -> Increment {
        .daily(Increment.Day(from: dateComponents)!)
    }
    
    fileprivate static var hours: Int { 24 }
}

extension Increment.TwoHour: Period {
    fileprivate static func createIncrement(dateComponents: DateComponents) -> Increment {
        .twoHourly(Increment.Day(from: dateComponents)!, Increment.TwoHour(from: dateComponents)!)
    }
    
    fileprivate static var hours: Int { 2 }
}

private extension Increment.Day {
    init?(from components: DateComponents) {
        guard let year = components.year else { return nil }
        guard let month = components.month else { return nil }
        guard let day = components.day else { return nil }
        self.init(year: year, month: month, day: day)
    }
}

private extension Increment.TwoHour {
    init?(from components: DateComponents) {
        guard let hour = components.hour else { return nil }
        self.init(value: hour)
    }
}
