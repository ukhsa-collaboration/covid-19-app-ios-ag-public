//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Domain

public class MockVenueDecoder: VenueDecoding {
    
    // payload is ignored as we generate the scanned Venue(s) from values stored in MockScenario
    // (we're assuming that payload actually comes from MockCameraManager which just sends us 'ignored venue id')
    public func decode(_ /* payload */: String) throws -> [Venue] {
        
        let venueIds = MockDataProvider.shared.fakeCheckinsVenueID.components(separatedBy: ",")
        let venueOrgs = MockDataProvider.shared.fakeCheckinsVenueOrg.components(separatedBy: ",")
        let venuePostcodes = MockDataProvider.shared.fakeCheckinsVenuePostcode.components(separatedBy: ",")
        
        let zipped = zip(Array(zip(venueIds, venueOrgs)), venuePostcodes)
        
        return zipped.map { arg0, postcode in
            let (id, org) = arg0
            return Venue(
                id: id.trimmingCharacters(in: .whitespacesAndNewlines),
                organisation: org.trimmingCharacters(in: .whitespacesAndNewlines),
                postcode: postcode.trimmingCharacters(in: .whitespacesAndNewlines)
            )
        }
    }
}
