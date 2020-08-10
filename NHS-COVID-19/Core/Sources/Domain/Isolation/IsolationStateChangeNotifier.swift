//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation
import UserNotifications

struct IsolationStateChangeNotifier {
    
    var notificationManager: UserNotificationManaging
    
    func alertUserToChanges<P: Publisher>(in risk: P) -> AnyCancellable where P.Output == IsolationLogicalState, P.Failure == Never {
        risk.removeDuplicates()
            .sink { state in
                switch state {
                case .notIsolating, .isolationFinishedButNotAcknowledged:
                    self.notificationManager.removePending(type: .isolationState)
                case .isolating(let isolation, _, _):
                    self.notificationManager.add(
                        type: .isolationState,
                        at: isolation.endNotificationDateComponents,
                        withCompletionHandler: nil
                    )
                }
            }
    }
    
}

private extension Isolation {
    
    var endNotificationDateComponents: DateComponents {
        mutating(untilStartOfDay.gregorianDay.advanced(by: -1).dateComponents) {
            // `GregorianDay` doesn’t know the user’s time zone.
            // Let the OS convert this to correct time zone
            $0.calendar = nil
            $0.timeZone = nil
            
            $0.hour = 21
        }
    }
    
}
