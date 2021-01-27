//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Domain
import Foundation
import Interface
import Localization

struct SendKeysLoadingFlowViewControllerInteractor: SendKeysLoadingFlowViewController.Interacting {
    var acknowledgement: TestResultAcknowledgementState.PositiveResultAcknowledgement
    
    let openURL: (URL) -> Void
    
    func didTapOnlineServicesLink() {
        openURL(ExternalLink.nhs111Online.url)
    }
    
    func didTapExposureFAQLink() {
        openURL(ExternalLink.exposureFAQs.url)
    }
    
    func shareKeys() -> AnyPublisher<Void, Error> {
        acknowledgement.acknowledge().regulate(as: .modelChange)
    }
    
    func didTapCancel() {
        acknowledgement.acknowledgeWithoutSending()
    }
    
    func acknowledgeWithoutKeySharing() {
        acknowledgement.acknowledgeWithoutSending()
    }
}
