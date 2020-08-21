//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import Localization

public enum ExternalLink {
    case privacy
    case ourPolicies
    case faq
    case aboutTheApp
    case accessibilityStatement
    case isolationAdvice
    case generalAdvice
    case moreInfoOnPostcodeRisk
    case bookATestForSomeoneElse
    case testingPrivacyNotice
    case nhs111Online
    case howThisAppWorks
    
    var url: URL {
        let url: String
        switch self {
        case .privacy:
            url = localize(.link_privacy)
        case .ourPolicies:
            url = localize(.link_our_policies)
        case .faq:
            url = localize(.link_faq)
        case .aboutTheApp:
            url = localize(.link_about_the_app)
        case .accessibilityStatement:
            url = localize(.link_accessibility_statement)
        case .isolationAdvice:
            url = localize(.link_isolation_advice)
        case .generalAdvice:
            url = localize(.link_general_advice)
        case .moreInfoOnPostcodeRisk:
            url = localize(.link_more_info_on_postcode_risk)
        case .bookATestForSomeoneElse:
            url = localize(.link_book_a_test_for_someone_else)
        case .testingPrivacyNotice:
            url = localize(.link_testing_privacy_notice)
        case .nhs111Online:
            url = localize(.link_nhs111_online)
        case .howThisAppWorks:
            url = localize(.link_how_this_app_works)
        }
        return URL(string: url)!
    }
}
