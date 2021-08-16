//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Foundation
import UserNotifications

struct SelfIsolationChangeNotifier {
    var currentDateProviding: DateProviding
    var notificationManager: UserNotificationManaging
    
    func scheduleSelfIsolationReminderNotification() {
        let twentyFourHours: Double = 24 * 60 * 60
        let dateComponents = Calendar.current.dateComponents(
            [.year, .month, .day, .hour, .minute, .second],
            from: currentDateProviding.currentDate.advanced(by: twentyFourHours)
        )
        notificationManager.add(
            type: .selfIsolation,
            at: dateComponents,
            withCompletionHandler: nil
        )
    }
    
    func removePendingOrUndelivered() {
        notificationManager.removePending(type: .selfIsolation)
        notificationManager.removeAllDelivered(for: .selfIsolation)
    }
    
    func removesNotificationsForChanges<P: Publisher>(in risk: P) -> AnyCancellable where P.Output == IsolationLogicalState, P.Failure == Never {
        risk.removeDuplicates()
            .sink { state in
                switch state {
                case .notIsolating, .isolationFinishedButNotAcknowledged:
                    self.removePendingOrUndelivered()
                case .isolating:
                    break
                }
            }
    }
    
}
