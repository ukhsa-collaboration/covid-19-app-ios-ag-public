//
// Copyright © 2021 DHSC. All rights reserved.
//

import Domain
import Interface
import Localization
import UIKit

struct DailyContactTestingConfirmationInteractor: DailyContactTestingConfirmationViewController.Interacting {
    
    private var action: () -> Void
    
    func didTapConfirm() {
        action()
    }
    
    init(action: @escaping () -> Void) {
        self.action = action
    }
    
}
