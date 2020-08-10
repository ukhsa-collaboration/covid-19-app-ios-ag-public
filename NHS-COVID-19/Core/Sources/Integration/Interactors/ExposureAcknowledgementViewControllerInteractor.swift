//
// Copyright © 2020 NHSX. All rights reserved.
//

import Domain
import Foundation
import Interface

struct ExposureAcknowledgementViewControllerInteractor: ExposureAcknowledgementViewController.Interacting {
    private var externalLinkOpener: ExternalLinkOpening
    private var _acknowledge: () -> Void
    
    init(externalLinkOpener: ExternalLinkOpening, acknowledge: @escaping () -> Void) {
        self.externalLinkOpener = externalLinkOpener
        _acknowledge = acknowledge
    }
    
    func acknowledge() {
        _acknowledge()
    }
    
    func didTapOnlineLink() {
        guard let url = URL(string: ExternalLink.nhs111Online.rawValue) else { return }
        externalLinkOpener.openExternalLink(url: url)
    }
}
