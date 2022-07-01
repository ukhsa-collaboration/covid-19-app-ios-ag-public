//
// Copyright © 2021 DHSC. All rights reserved.
//

import Interface

struct PlodTestResultInteractor: PlodTestResultViewControllerInteracting {
    func didTapReturnHome() {
        acknowledge()
    }

    var acknowledge: () -> Void
}
