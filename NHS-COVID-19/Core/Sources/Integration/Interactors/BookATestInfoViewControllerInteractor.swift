//
// Copyright © 2020 NHSX. All rights reserved.
//

import Domain
import Interface

public struct BookATestInfoViewControllerInteractor: BookATestInfoViewControllerInteracting {
    
    private let _openExternalLink: (ExternalLink) -> Void
    private let _didTapBookATest: () -> Void
    
    public init(didTapBookATest: @escaping () -> Void, openExternalLink: @escaping (ExternalLink) -> Void) {
        _didTapBookATest = didTapBookATest
        _openExternalLink = openExternalLink
    }
    
    public func didTapBookATest() {
        _didTapBookATest()
    }
    
    public func didTapTestingPrivacyNotice() {
        _openExternalLink(ExternalLink.testingPrivacyNotice)
    }
    
    public func didTapAppPrivacyNotice() {
        _openExternalLink(ExternalLink.privacy)
    }
    
    public func didTapBookATestForSomeoneElse() {
        _openExternalLink(ExternalLink.bookATestForSomeoneElse)
    }
}
