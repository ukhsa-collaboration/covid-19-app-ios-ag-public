//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

public struct CheckIn: Codable, Equatable {
    var isRisky: Bool
    var circuitBreakerApproval: CircuitBreakerApproval
    
    public var venueId: String
    public var venueName: String
    public var checkedIn: UTCHour
    public var checkedOut: UTCHour
    
    var checkedInInterval: DateInterval {
        DateInterval(start: checkedIn.date, end: checkedOut.date)
    }
    
    init(venueId: String, venueName: String, checkedIn: UTCHour, checkedOut: UTCHour, isRisky: Bool) {
        self.venueId = venueId
        self.venueName = venueName
        self.checkedIn = checkedIn
        self.checkedOut = checkedOut
        self.isRisky = isRisky
        circuitBreakerApproval = .pending
    }
    
    init(venue: Venue, checkedIn: UTCHour, checkedOut: UTCHour, isRisky: Bool) {
        self.init(venueId: venue.id, venueName: venue.organisation, checkedIn: checkedIn, checkedOut: checkedOut, isRisky: isRisky)
    }
}

extension CheckIn {
    init(venue: Venue, checkedInDate: Date, untilEndOfDayIn: Calendar = .current, isRisky: Bool = false) {
        let checkedIn = UTCHour(roundedDownToQuarter: checkedInDate)
        let minimumCheckout = UTCHour(roundedUpToQuarter: checkedInDate)
        let checkout = UTCHour(roundedDownToQuarter: LocalDay(date: checkedInDate, timeZone: untilEndOfDayIn.timeZone).advanced(by: 1).startOfDay)
        self.init(venue: venue, checkedIn: checkedIn, checkedOut: max(minimumCheckout, checkout), isRisky: isRisky)
    }
}
