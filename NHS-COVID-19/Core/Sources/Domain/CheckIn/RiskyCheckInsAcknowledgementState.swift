//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation

public enum RiskyCheckInsAcknowledgementState {
    case notNeeded
    case needed(acknowledge: () -> Void, venueName: String, checkInDate: Date, resolution: RiskyVenueResolution)
}

public enum RiskyVenueResolution {
    case warnAndInform
    case warnAndBookATest
    
    init(_ messageType: RiskyVenue.MessageType) {
        switch messageType {
        case .warnAndInform:
            self = .warnAndInform
        case .warnAndBookATest:
            self = .warnAndBookATest
        }
    }
}
