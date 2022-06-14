//
// Copyright © 2022 DHSC. All rights reserved.
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
    case getTested
    case reportLFDResultsOnGovDotUK
    case downloadNHSApp
    case governmentGuidance
    case findLocalAuthority
    case approvedVaccinesInfo
    case isolationNote
    case localCovidStatsInfo
    case getRapidTestsAsymptomaticWales
    case guidanceForContactsInEngland
    case guidanceForHouseholdContactsInEngland
    case guidanceForContactsInWales
    case getTestedWalesLink
    case guidanceHubEnglandLink
    case guidanceHubCheckSymptomsLink
    case guidanceHubLatestLink
    case guidanceHubPositiveTestLink
    case guidanceHubTravellingAbroadLink
    case guidanceHubSSPLink
    case guidanceHubEnquiriesLink
    case guidanceHubWalesLink1
    case guidanceHubWalesLink2
    case guidanceHubWalesLink3
    case guidanceHubWalesLink4
    case guidanceHubWalesLink5
    case guidanceHubWalesLink6
    case guidanceHubWalesLink7
    case didTapSymptomaticCase
    case didTapSymptomCheckerNormalActivities

    
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
        case .approvedVaccinesInfo:
            return localizeURL(.link_approved_vaccines_info)
        case .isolationNote:
            return localizeURL(.link_isolation_note)
        case .localCovidStatsInfo:
            return localizeURL(.local_statistics_main_screen_dashboard_url)
        case .getRapidTestsAsymptomaticWales:
            return localizeURL(.contact_case_start_isolation_book_lfd_test_url)
        case .guidanceForContactsInEngland:
            return localizeURL(.contact_case_guidance_for_contacts_in_england_url)
        case .guidanceForHouseholdContactsInEngland:
            return localizeURL(.risky_contact_opt_out_further_advice_link_url)
        case .guidanceForContactsInWales:
            return localizeURL(.risky_contact_opt_out_primary_button_url_wales)
        case .getTestedWalesLink:
            return localizeURL(.get_tested_wales_link_url)
        case .guidanceHubEnglandLink:
            return localizeURL(.covid_guidance_hub_for_england_url)
        case .guidanceHubCheckSymptomsLink:
            return localizeURL(.covid_guidance_hub_check_symptoms_url)
        case .guidanceHubLatestLink:
            return localizeURL(.covid_guidance_hub_latest_url)
        case.guidanceHubPositiveTestLink:
            return localizeURL(.covid_guidance_hub_positive_test_result_url)
        case.guidanceHubTravellingAbroadLink:
            return localizeURL(.covid_guidance_hub_travelling_abroad_url)
        case.guidanceHubSSPLink:
            return localizeURL(.covid_guidance_hub_check_ssp_url)
        case.guidanceHubEnquiriesLink:
            return localizeURL(.covid_guidance_hub_enquiries_url)
        case .guidanceHubWalesLink1:
            return localizeURL(.covid_guidance_hub_wales_button_one_url)
        case .guidanceHubWalesLink2:
            return localizeURL(.covid_guidance_hub_wales_button_two_url)
        case .guidanceHubWalesLink3:
            return localizeURL(.covid_guidance_hub_wales_button_three_url)
        case .guidanceHubWalesLink4:
            return localizeURL(.covid_guidance_hub_wales_button_four_url)
        case .guidanceHubWalesLink5:
            return localizeURL(.covid_guidance_hub_wales_button_five_url)
        case .guidanceHubWalesLink6:
            return localizeURL(.covid_guidance_hub_wales_button_six_url)
        case .guidanceHubWalesLink7:
            return localizeURL(.covid_guidance_hub_wales_button_seven_url)
        case.didTapSymptomaticCase:
            return localizeURL(.symptom_checker_advice_notice_continue_normal_activities_link_url)
        case.didTapSymptomCheckerNormalActivities:
            return localizeURL(.symptom_checker_advice_notice_stay_at_home_link_url)
        }
    }
}
