//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import Interface
import UIKit

struct RiskyVenueInformationInteractor: RiskyVenueInformationViewController.Interacting {

    private var _goHomeTapped: () -> Void

    init(goHomeTapped: @escaping () -> Void) {
        _goHomeTapped = goHomeTapped
    }

    func goHomeTapped() {
        _goHomeTapped()
    }
}
