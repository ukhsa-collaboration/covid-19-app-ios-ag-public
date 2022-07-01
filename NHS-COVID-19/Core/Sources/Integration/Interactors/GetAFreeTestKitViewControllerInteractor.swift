//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import Interface

struct GetAFreeTestKitViewControllerInteractor: GetAFreeTestKitViewController.Interacting {
    private let _didTapAlreadyHaveATest: () -> Void
    private let _didTapBookATest: () -> Void

    init(didTapAlreadyHaveATest: @escaping () -> Void, didTapBookATest: @escaping () -> Void) {
        _didTapAlreadyHaveATest = didTapAlreadyHaveATest
        _didTapBookATest = didTapBookATest
    }

    func didTapAlreadyHaveATest() {
        _didTapAlreadyHaveATest()
    }

    func didTapBookATest() {
        _didTapBookATest()
    }
}
