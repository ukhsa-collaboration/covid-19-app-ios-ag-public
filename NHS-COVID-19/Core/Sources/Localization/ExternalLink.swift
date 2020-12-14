//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

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
    case exposureFAQs
    case howThisAppWorks
    case provideFeedback
    case visitUKgov
    case financialSupportEngland
    case financialSupportWales
    case financialSupportPrivacyNotice
    
    public var url: URL {
        switch self {
        case .privacy:
            return localizeURL(.link_privacy)
        case .ourPolicies:
            return localizeURL(.link_our_policies)
        case .faq:
            return localizeURL(.link_faq)
        case .aboutTheApp:
            return localizeURL(.link_about_the_app)
        case .accessibilityStatement:
            return localizeURL(.link_accessibility_statement)
        case .isolationAdvice:
            return localizeURL(.link_isolation_advice)
        case .generalAdvice:
            return localizeURL(.link_general_advice)
        case .moreInfoOnPostcodeRisk:
            return localizeURL(.link_more_info_on_postcode_risk)
        case .bookATestForSomeoneElse:
            return localizeURL(.link_book_a_test_for_someone_else)
        case .testingPrivacyNotice:
            return localizeURL(.link_testing_privacy_notice)
        case .nhs111Online:
            return localizeURL(.link_nhs111_online)
        case .howThisAppWorks:
            return localizeURL(.link_how_this_app_works)
        case .provideFeedback:
            return localizeURL(.link_provide_feedback)
        case .exposureFAQs:
            return localizeURL(.link_exposure_faq)
        case .visitUKgov:
            return localizeURL(.link_visit_uk_gov)
        case .financialSupportEngland:
            return localizeURL(.financial_support_help_england_link)
        case .financialSupportWales:
            return localizeURL(.financial_support_help_wales_link)
        case .financialSupportPrivacyNotice:
            return localizeURL(.financial_support_privacy_notice_link)
        }
    }
}
