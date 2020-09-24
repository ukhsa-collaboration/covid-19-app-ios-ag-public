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
    
    init(didTapCancel: (() -> Void)?, bookATest: @escaping () -> Void, openURL: @escaping (URL) -> Void) {
        didTapPrimaryButton = bookATest
        didTapOnlineServicesLink = { openURL(ExternalLink.nhs111Online.url) }
        self.didTapCancel = didTapCancel
    }
}
