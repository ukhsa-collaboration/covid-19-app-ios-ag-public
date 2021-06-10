//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import Interface
import Localization

struct BookAFollowUpTestInteractor: BookAFollowUpTestViewController.Interacting {
    let didTapPrimaryButton: () -> Void
    let didTapOnlineServicesLink: () -> Void
    let didTapCancel: () -> Void
    
    init(
        didTapPrimaryButton: @escaping () -> Void,
        didTapCancel: @escaping () -> Void,
        openURL: @escaping (URL) -> Void
    ) {
        self.didTapPrimaryButton = didTapPrimaryButton
        didTapOnlineServicesLink = { openURL(ExternalLink.nhs111Online.url) }
        self.didTapCancel = didTapCancel
    }
}
