//
// Copyright © 2021 DHSC. All rights reserved.
//

import Interface

struct UnknownTestResultInteractor: UnknownTestResultsViewControllerInteracting {
    func didTapClose() {
        acknowledge()

    }

    func didTapOpenStore() {
        acknowledge()
        openAppStore()
    }

    var acknowledge: () -> Void
    var openAppStore: () -> Void
}
