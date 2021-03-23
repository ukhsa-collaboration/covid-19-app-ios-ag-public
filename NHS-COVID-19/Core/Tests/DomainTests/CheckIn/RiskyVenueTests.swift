//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import XCTest
@testable import Domain

class RiskyVenueTests: XCTestCase {
    
    func testSortRiskyVenueBasedOnSeverityLevel() {
        let riskyVenues: [RiskyVenue] = [
            RiskyVenue(id: UUID().uuidString, riskyInterval: UTCHour.riskyTimeInterval, messageType: .warnAndInform),
            RiskyVenue(id: UUID().uuidString, riskyInterval: UTCHour.riskyTimeInterval, messageType: .warnAndBookATest),
            RiskyVenue(id: UUID().uuidString, riskyInterval: UTCHour.riskyTimeInterval, messageType: .warnAndInform),
        ]
        
        let sortedRiskyVenues = riskyVenues.sorted()
        
        XCTAssertEqual(sortedRiskyVenues.first, riskyVenues[1])
    }
}
