//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import Interface
import Localization

struct PositiveTestResultNoIsolationInteractor: NonNegativeTestResultNoIsolationViewControllerInteracting {
    let openURL: (URL) -> Void
    
    var didTapPrimaryButton: () -> Void
    var didTapOnlineServicesLink: () -> Void
    var didTapCancel: (() -> Void)?
    
    init(
        openURL: @escaping (URL) -> Void,
        didTapPrimaryButton: @escaping () -> Void,
        didTapCancel: (() -> Void)? = nil
    ) {
        self.openURL = openURL
        self.didTapPrimaryButton = didTapPrimaryButton
        didTapOnlineServicesLink = { openURL(ExternalLink.nhs111Online.url) }
        self.didTapCancel = didTapCancel
    }
    
}
