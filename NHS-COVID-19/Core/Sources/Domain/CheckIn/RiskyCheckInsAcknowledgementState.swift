//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

public enum RiskyCheckInsAcknowledgementState {
    case notNeeded
    case needed(acknowledge: () -> Void, venueName: String, checkInDate: Date)
}
