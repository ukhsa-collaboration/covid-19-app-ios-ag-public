//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import Interface
import Localization

struct VoidTestResultWithIsolationInteractor: NonNegativeTestResultWithIsolationViewController.Interacting {
    var didTapOnlineServicesLink: () -> Void
    var didTapPrimaryButton: () -> Void
    var didTapExposureFAQLink: () -> Void
    var didTapCancel: (() -> Void)?
    
    init(didTapPrimaryButton: @escaping () -> Void, openURL: @escaping (URL) -> Void, didTapCancel: @escaping () -> Void) {
        self.didTapPrimaryButton = didTapPrimaryButton
        didTapOnlineServicesLink = { openURL(ExternalLink.nhs111Online.url) }
        didTapExposureFAQLink = { openURL(ExternalLink.exposureFAQs.url) }
        self.didTapCancel = didTapCancel
    }
}
