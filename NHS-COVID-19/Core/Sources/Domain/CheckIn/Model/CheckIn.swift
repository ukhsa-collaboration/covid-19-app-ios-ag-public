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
    public var id: String
    
    var checkedInInterval: DateInterval {
        DateInterval(start: checkedIn.date, end: checkedOut.date)
    }
    
    init(
        venueId: String,
        venueName: String,
        checkedIn: UTCHour,
        checkedOut: UTCHour,
        isRisky: Bool
    ) {
        self.venueId = venueId
        self.venueName = venueName
        self.checkedIn = checkedIn
        self.checkedOut = checkedOut
        self.isRisky = isRisky
        id = UUID().uuidString
        circuitBreakerApproval = .pending
    }
    
    init(venue: Venue, checkedIn: UTCHour, checkedOut: UTCHour, isRisky: Bool) {
        self.init(
            venueId: venue.id,
            venueName: venue.organisation,
            checkedIn: checkedIn,
            checkedOut: checkedOut,
            isRisky: isRisky
        )
    }
    
    private enum CodingKeys: String, CodingKey {
        case isRisky
        case circuitBreakerApproval
        case venueId
        case venueName
        case checkedIn
        case checkedOut
        case id
    }
    
    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        isRisky = try container.decode(Bool.self, forKey: .isRisky)
        circuitBreakerApproval = try container.decode(CircuitBreakerApproval.self, forKey: .circuitBreakerApproval)
        venueId = try container.decode(String.self, forKey: .venueId)
        venueName = try container.decode(String.self, forKey: .venueName)
        checkedIn = try container.decode(UTCHour.self, forKey: .checkedIn)
        checkedOut = try container.decode(UTCHour.self, forKey: .checkedOut)
        id = try container.decodeIfPresent(String.self, forKey: .id) ?? UUID().uuidString
    }
    
}

extension CheckIn {
    init(venue: Venue, checkedInDate: Date, untilEndOfDayIn: Calendar = .current, isRisky: Bool = false) {
        let checkedIn = UTCHour(roundedDownToQuarter: checkedInDate)
        let minimumCheckout = UTCHour(roundedUpToQuarter: checkedInDate)
        let checkout = UTCHour(roundedDownToQuarter: LocalDay(date: checkedInDate, timeZone: untilEndOfDayIn.timeZone).advanced(by: 1).startOfDay)
        self.init(
            venue: venue,
            checkedIn: checkedIn,
            checkedOut: max(minimumCheckout, checkout),
            isRisky: isRisky
        )
    }
}
