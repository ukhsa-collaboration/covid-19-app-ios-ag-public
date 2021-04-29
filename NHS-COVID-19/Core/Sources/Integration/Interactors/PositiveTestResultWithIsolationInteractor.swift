//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import Interface
import Localization

struct PositiveTestResultWithIsolationInteractor: NonNegativeTestResultWithIsolationViewControllerInteracting {
    let openURL: (URL) -> Void
    
    var didTapOnlineServicesLink: () -> Void
    var didTapExposureFAQLink: () -> Void
    var didTapPrimaryButton: () -> Void
    var didTapCancel: (() -> Void)?
    
    init(
        openURL: @escaping (URL) -> Void,
        didTapPrimaryButton: @escaping () -> Void,
        didTapCancel: (() -> Void)? = nil
    ) {
        self.openURL = openURL
        didTapOnlineServicesLink = { openURL(ExternalLink.nhs111Online.url) }
        didTapExposureFAQLink = { openURL(ExternalLink.exposureFAQs.url) }
        self.didTapPrimaryButton = didTapPrimaryButton
        self.didTapCancel = didTapCancel
    }
}
