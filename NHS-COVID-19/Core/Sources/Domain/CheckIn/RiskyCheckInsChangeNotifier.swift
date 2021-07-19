//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Foundation
import UserNotifications

struct RiskyCheckInsChangeNotifier {
    
    var notificationManager: UserNotificationManaging
    
    func alertUserToChanges<P: Publisher>(in risk: P) -> AnyCancellable where P.Output == RiskyVenue.MessageType?, P.Failure == Never {
        risk.removeDuplicates()
            .dropFirst()
            .sink { venueMessageType in
                guard let venueMessageType = venueMessageType else {
                    return
                }
                switch venueMessageType {
                case .warnAndInform:
                    Metrics.signpost(.receivedRiskyVenueM1Warning)
                    self.notificationManager.add(type: .venue(.warnAndInform), at: nil, withCompletionHandler: nil)
                case .warnAndBookATest:
                    Metrics.signpost(.receivedRiskyVenueM2Warning)
                    self.notificationManager.add(type: .venue(.warnAndBookATest), at: nil, withCompletionHandler: nil)
                }
            }
    }
    
}
