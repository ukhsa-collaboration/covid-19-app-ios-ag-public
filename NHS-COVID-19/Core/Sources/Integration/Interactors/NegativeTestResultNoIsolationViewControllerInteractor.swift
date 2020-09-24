//
// Copyright © 2020 NHSX. All rights reserved.
//

import Domain
import Foundation
import Interface
import Localization

struct NegativeTestResultNoIsolationViewControllerInteractor: NegativeTestResultNoIsolationViewController.Interacting {
    var _acknowledge: () -> Void
    let openURL: (URL) -> Void
    
    func didTapOnlineServicesLink() {
        openURL(ExternalLink.nhs111Online.url)
    }
    
    func didTapReturnHome() {
        _acknowledge()
    }
    
    func didTapFurtherAdviceLink() {}
}
