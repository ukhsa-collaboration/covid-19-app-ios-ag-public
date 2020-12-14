//
// Copyright © 2020 NHSX. All rights reserved.
//

enum CircuitBreakerType: Equatable {
    case exposureNotification(RiskInfo)
    case riskyVenue
    
    var endpointName: String {
        switch self {
        case .exposureNotification:
            return "exposure-notification"
        case .riskyVenue:
            return "venue"
        }
    }
}
