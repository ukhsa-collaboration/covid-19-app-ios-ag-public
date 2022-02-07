//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation

public enum ExternalLink: CaseIterable {
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
    case nhsGuidance
    case exposureFAQs
    case howThisAppWorks
    case provideFeedback
    case visitUKgov
    case financialSupportEngland
    case financialSupportWales
    case financialSupportPrivacyNotice
    case cantRunThisAppFAQs
    case findTestCenter
    case getTested
    case reportLFDResultsOnGovDotUK
    case downloadNHSApp
    case governmentGuidance
    case findLocalAuthority
    case bookPCRTest
    case approvedVaccinesInfo
    case isolationNote
    case localCovidStatsInfo
    case getRapidTestsAsymptomaticWales
    
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
        case .nhsGuidance:
            return localizeURL(.link_nhs_guidance)
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
        case .cantRunThisAppFAQs:
            return localizeURL(.link_cant_run_this_app_faq)
        case .findTestCenter:
            return localizeURL(.link_find_test_center)
        case .getTested:
            return localizeURL(.link_nhs_get_tested)
        case .reportLFDResultsOnGovDotUK:
            return localizeURL(.link_test_result_gov_uk_rapid_result_report_url)
        case .downloadNHSApp:
            return localizeURL(.link_download_nhs_app)
        case .governmentGuidance:
            return localizeURL(.link_government_guidance)
        case .findLocalAuthority:
            return localizeURL(.link_find_local_authority)
        case .bookPCRTest:
            return localizeURL(.new_no_symptoms_screen_pcr_testing_link_url)
        case .approvedVaccinesInfo:
            return localizeURL(.link_approved_vaccines_info)
        case .isolationNote:
            return localizeURL(.link_isolation_note)
        case .localCovidStatsInfo:
            return localizeURL(.local_statistics_main_screen_dashboard_url)
        case .getRapidTestsAsymptomaticWales:
            return localizeURL(.contact_case_start_isolation_book_lfd_test_url)
        }
    }
}
