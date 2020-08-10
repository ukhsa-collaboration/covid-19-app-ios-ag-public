//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation
import UserNotifications

struct RiskyCheckInsChangeNotifier {
    
    var notificationManager: UserNotificationManaging
    
    func alertUserToChanges<P: Publisher>(in risk: P) -> AnyCancellable where P.Output == [CheckIn], P.Failure == Never {
        risk.removeDuplicates()
            .sink { riskyCheckIns in
                guard !riskyCheckIns.isEmpty else { return }
                self.notificationManager.add(type: .venue, at: nil, withCompletionHandler: nil)
            }
    }
    
}
