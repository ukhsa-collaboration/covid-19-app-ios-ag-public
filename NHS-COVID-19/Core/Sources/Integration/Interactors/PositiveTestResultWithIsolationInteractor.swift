//
// Copyright © 2020 NHSX. All rights reserved.
//

import Interface

struct PositiveTestResultWithIsolationInteractor: NonNegativeTestResultWithIsolationViewControllerInteracting {
    var didTapOnlineServicesLink: () -> Void
    var didTapExposureFAQLink: () -> Void
    var didTapPrimaryButton: () -> Void
    var didTapCancel: (() -> Void)?
}
