//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import Interface
import UIKit

struct CheckInInteractor: CheckInFlowViewController.Interacting {
    
    var _openSettings: () -> Void
    var _process: (String) throws -> CheckInDetail
    
    func openSettings() {
        _openSettings()
    }
    
    func process(_ payload: String) throws -> CheckInDetail {
        try _process(payload)
    }
}
