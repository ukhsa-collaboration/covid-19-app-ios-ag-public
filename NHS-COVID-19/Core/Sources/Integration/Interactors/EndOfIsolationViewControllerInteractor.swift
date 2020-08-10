//
// Copyright © 2020 NHSX. All rights reserved.
//

import Domain
import Foundation
import Interface

struct EndOfIsolationViewControllerInteractor: EndOfIsolationViewController.Interacting {
    
    var acknowledge: () -> Void
    let externalLinkOpener: ExternalLinkOpening
    
    func didTapOnlineServicesLink() {
        guard let link = URL(string: ExternalLink.nhs111Online.rawValue) else { return }
        externalLinkOpener.openExternalLink(url: link)
    }
    
    func didTapReturnHome() {
        acknowledge()
    }
    
    func didTapFurtherAdviceLink() {}
    
}
