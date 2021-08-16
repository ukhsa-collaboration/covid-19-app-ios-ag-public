//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Domain
import Foundation
import Interface
import Localization

struct LinkTestResultInteractor: LinkTestResultViewController.Interacting {
    
    var openURL: (URL) -> Void
    var onCancel: () -> Void
    var onSubmit: (String) -> AnyPublisher<Void, LinkTestValidationError>
    
    func cancel() {
        onCancel()
    }
    
    func submit(testCode: String) -> AnyPublisher<Void, LinkTestValidationError> {
        return onSubmit(testCode).eraseToAnyPublisher()
    }
    
    func reportRapidTestResultsOnGovDotUKTapped() {
        openURL(ExternalLink.reportLFDResultsOnGovDotUK.url)
    }
}
