//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import Interface
import UIKit

struct RiskyVenueInformationInteractor: RiskyVenueInformationViewController.Interacting {
    private var _goHome: () -> Void
    
    init(goHome: @escaping () -> Void) {
        _goHome = goHome
    }
    
    func goHome() {
        _goHome()
    }
}
