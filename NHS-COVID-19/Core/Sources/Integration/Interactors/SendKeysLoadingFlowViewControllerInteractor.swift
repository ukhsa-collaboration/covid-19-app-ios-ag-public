//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Domain
import Foundation
import Interface

struct SendKeysLoadingFlowViewControllerInteractor: SendKeysLoadingFlowViewController.Interacting {
    var acknowledgement: TestResultAcknowledgementState.PositiveResultAcknowledgement
    
    let externalLinkOpener: ExternalLinkOpening
    
    func didTapOnlineServicesLink() {
        guard let link = URL(string: ExternalLink.nhs111Online.rawValue) else { return }
        externalLinkOpener.openExternalLink(url: link)
    }
    
    func shareKeys() -> AnyPublisher<Void, Error> {
        acknowledgement.acknowledge().regulate(as: .modelChange)
    }
    
    func didTapCancel() {
        acknowledgement.acknowledgeWithoutSending()
    }
}
