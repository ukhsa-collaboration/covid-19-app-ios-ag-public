//
// Copyright © 2020 NHSX. All rights reserved.
//

import Domain
import Foundation
import Interface

struct EndOfIsolationViewControllerInteractor: EndOfIsolationViewController.Interacting {
    
    var acknowledge: () -> Void
    let openURL: (URL) -> Void
    
    func didTapOnlineServicesLink() {
        openURL(ExternalLink.nhs111Online.url)
    }
    
    func didTapReturnHome() {
        acknowledge()
    }
    
    func didTapFurtherAdviceLink() {}
    
}
