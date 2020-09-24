//
// Copyright © 2020 NHSX. All rights reserved.
//

import Domain
import Foundation
import Interface
import Localization

public struct BookATestInfoViewControllerInteractor: BookATestInfoViewControllerInteracting {
    
    private let _openURL: (URL) -> Void
    private let _didTapBookATest: () -> Void
    
    public init(didTapBookATest: @escaping () -> Void, openURL: @escaping (URL) -> Void) {
        _didTapBookATest = didTapBookATest
        _openURL = openURL
    }
    
    public func didTapBookATest() {
        _didTapBookATest()
    }
    
    public func didTapTestingPrivacyNotice() {
        _openURL(ExternalLink.testingPrivacyNotice.url)
    }
    
    public func didTapAppPrivacyNotice() {
        _openURL(ExternalLink.privacy.url)
    }
    
    public func didTapBookATestForSomeoneElse() {
        _openURL(ExternalLink.bookATestForSomeoneElse.url)
    }
}
