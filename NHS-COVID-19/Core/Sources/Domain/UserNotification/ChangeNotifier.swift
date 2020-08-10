//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation
import UserNotifications

struct ChangeNotifier {
    
    var notificationManager: UserNotificationManaging
    
    func alertUserToChanges<P: Publisher>(in risk: P, type: UserNotificationType, shouldSend: @escaping (P.Output) -> Bool = { _ in true }) -> AnyCancellable where P.Output: Equatable, P.Failure == Never {
        risk.removeDuplicates()
            .dropFirst()
            .sink { output in
                if shouldSend(output) {
                    self.notificationManager.add(type: type, at: nil, withCompletionHandler: nil)
                }
            }
    }
    
}
