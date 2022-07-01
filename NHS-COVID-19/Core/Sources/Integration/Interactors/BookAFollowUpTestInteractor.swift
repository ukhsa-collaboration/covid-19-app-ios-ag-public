//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import Interface
import Localization

struct BookAFollowUpTestInteractor: BookAFollowUpTestViewController.Interacting {
    let didTapPrimaryButton: () -> Void
    let didTapNHSGuidanceLink: () -> Void
    let didTapCancel: () -> Void

    init(
        didTapPrimaryButton: @escaping () -> Void,
        didTapCancel: @escaping () -> Void,
        openURL: @escaping (URL) -> Void
    ) {
        self.didTapPrimaryButton = didTapPrimaryButton
        didTapNHSGuidanceLink = { openURL(ExternalLink.nhsGuidance.url) }
        self.didTapCancel = didTapCancel
    }
}
