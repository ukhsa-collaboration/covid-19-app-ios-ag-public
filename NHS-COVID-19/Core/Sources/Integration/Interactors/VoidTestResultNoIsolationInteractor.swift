//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import Interface
import Localization

struct VoidTestResultNoIsolationInteractor: NonNegativeTestResultNoIsolationViewController.Interacting {
    var didTapCancel: (() -> Void)?
    var didTapOnlineServicesLink: () -> Void
    var didTapPrimaryButton: () -> Void

    init(didTapCancel: (() -> Void)?, didTapPrimaryButton: @escaping () -> Void, openURL: @escaping (URL) -> Void) {
        self.didTapPrimaryButton = didTapPrimaryButton
        didTapOnlineServicesLink = { openURL(ExternalLink.nhs111Online.url) }
        self.didTapCancel = didTapCancel
    }
}
