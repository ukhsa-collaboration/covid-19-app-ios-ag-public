//
// Copyright © 2020 NHSX. All rights reserved.
//

import Interface

struct PositiveTestResultNoIsolationInteractor: NonNegativeTestResultNoIsolationViewControllerInteracting {
    var didTapCancel: (() -> Void)?
    var didTapOnlineServicesLink: () -> Void
    var didTapPrimaryButton: () -> Void
}
