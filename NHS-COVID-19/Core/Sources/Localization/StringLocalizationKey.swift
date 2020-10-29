//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

public enum StringLocalizationKey: String, CaseIterable {
    case onboarding_strapline_title
    case onboarding_strapline_accessiblity_label
    
    case home_strapline_title
    case home_strapline_accessiblity_label
    case home_strapline_accessiblity_label_wls
    
    case unrecoverable_error_page_title
    case update_app_button_title
    case unrecoverable_error_title
    case unrecoverable_error_description
    
    case bluetooth_disabled_title
    case bluetooth_disabled_description
    
    case authorization_denied_title
    case authorization_denied_description
    case authorization_denied_action
    
    case authentication_code_title
    case authentication_code_description
    case authentication_code_textfield_heading
    case authentication_code_textfield_example
    case authentication_code_info_heading
    case authentication_code_info_description_1
    case authentication_code_info_example
    case authentication_code_info_description_2
    case authentication_code_button_title
    case authentication_code_error_description
    case authentication_code_textfield_label
    
    case start_onboarding_step_title
    case start_onboarding_step_subtitle
    case start_onboarding_step_1_header
    case start_onboarding_step_2_header
    case start_onboarding_step_3_header
    case start_onboarding_step_4_header
    case start_onboarding_step_1_description
    case start_onboarding_step_2_description
    case start_onboarding_step_3_description
    case start_onboarding_step_4_description
    case start_onboarding_button_title
    
    case postcode_entry_textfield_label
    case postcode_entry_example_label
    case postcode_entry_continue_button_title
    case postcode_entry_information_title
    case postcode_entry_information_description_1
    case postcode_entry_information_description_2
    case postcode_entry_step_title
    case postcode_entry_error_title
    case postcode_entry_error_description
    case postcode_entry_error_description_unsupported_country
    
    case permissions_onboarding_step_title
    case exposure_notification_permissions_onboarding_step_heading
    case exposure_notification_permissions_onboarding_step_body
    case permissions_onboarding_step_detail
    case permissions_continue_button_title
    
    case privacy_title
    case privacy_description_paragraph1
    case privacy_description_paragraph2
    case privacy_description_paragraph4
    case privacy_notice_label
    case terms_of_use_label
    case privacy_links_label
    case privacy_links_accessibility_label
    case privacy_yes_button
    case privacy_no_button
    case privacy_no_button_accessibility_label
    case privacy_header
    case data_header
    
    case home_diagnosis_button_title
    case home_testing_information_button_title
    case home_checkin_button_title
    case home_about_button_title
    case home_about_button_title_accessibility_label
    case home_toggle_exposure_notification_title
    case home_about_the_app_button_title
    case home_toggle_exposure_notification_on
    case home_toggle_exposure_notification_off
    case home_default_advice_button_title
    case home_isolation_advice_button_title
    
    case risk_level_indicator_contact_tracing_active
    case risk_level_indicator_contact_tracing_not_active
    case risk_level_high
    case risk_level_medium
    case risk_level_low
    case risk_level_more_info
    case risk_level_more_info_accessibility_label
    
    case risk_level_screen_low_body
    case risk_level_screen_medium_body
    case risk_level_screen_high_body
    case risk_level_screen_button
    case risk_level_screen_title
    case risk_level_screen_close_button
    
    case link_accessibility_hint
    
    case user_notification_explanation
    
    case checkin_camera_permission_denial_title
    case checkin_camera_permission_denial_explanation
    case checkin_camera_permission_close_button_title
    case checkin_open_settings_button_title
    case checkin_camera_failure_title
    case checkin_camera_failure_description
    case checkin_camera_failure_button_title
    case checkin_camera_qrcode_scanner_help_button_accessibility_label
    case checkin_scanning_failure_title
    case checkin_scanning_failure_description
    case checkin_scanning_failure_help_link_text
    case checkin_scanning_failure_more_description
    case checkin_scanning_failure_button_title
    case checkin_camera_qrcode_scanner_title
    case checkin_camera_qrcode_scanner_status_label
    case checkin_camera_qrcode_scanner_description_label
    case checkin_confirmation_explanation
    case checkin_confirmation_button_title
    case checkin_wrong_button_title
    case checkin_qrcode_scanner_close_button_title
    case checkin_information_title_new
    case checkin_information_description
    case checkin_information_help_scanning_section_title
    case checkin_information_help_scanning_section_description
    case checkin_information_whats_a_qr_code_section_title
    case checkin_information_whats_a_qr_code_section_description_new
    case checkin_information_how_it_works_section_title
    case checkin_information_how_it_works_section_description
    case checkin_information_how_it_helps_section_title
    case checkin_information_how_it_helps_section_description
    case checkin_risky_venue_information_description
    case checkin_risky_venue_information_button_title
    
    case qrcoder_scanner_status_starting
    case qrcoder_scanner_status_requesting_permission
    case qrcoder_scanner_status_scanning
    case qrcoder_scanner_status_processing
    case qrcoder_scanner_status_running
    case qrcoder_scanner_status_stopped
    
    case alert_postcode_risk_change_title
    case alert_postcode_risk_change_body
    case alert_venue_risk_change_title
    case alert_venue_risk_change_body
    case alert_venue_risk_isolate_title
    case alert_venue_risk_isolate_body
    case alert_isolation_state_change_title
    case alert_isolation_state_change_body
    case alert_exposure_detection_title
    case alert_exposure_detection_body
    case alert_test_result_received_title
    case alert_test_result_received_body
    case alert_app_availability_changed_title
    case alert_app_availability_changed_body
    case alert_latest_app_version_update_title
    case alert_latest_app_version_update_body
    
    case diagnosis_questionnaire_title
    case loading
    case loading_failed_action
    case loading_failed_heading
    case loading_failed_body
    
    case symptom_card_checked
    case symptom_card_unchecked
    
    case symptom_list_heading
    case symptom_list_description
    case symptom_list_primary_action
    case symptom_list_secondary_action
    case symptom_list_error_heading
    case symptom_list_error_description
    case symptom_list_discard_alert_title
    case symptom_list_discard_alert_body
    case symptom_list_discard_alert_cancel
    case symptom_list_discard_alert_discard
    
    case positive_symptoms_please_isolate_for
    case positive_symptoms_and_book_a_test
    case positive_symptoms_you_might_have_corona
    case positive_symptoms_explanation
    case positive_symptoms_corona_test_button
    case positive_symptoms_link_label
    
    case exposure_acknowledgement_self_isolate_for
    case exposure_acknowledgement_warning
    case exposure_acknowledgement_explaination_1
    case exposure_acknowledgement_explaination_2
    case exposure_acknowledgement_button
    case exposure_acknowledgement_link_label
    case exposure_acknowledgement_link
    
    case end_of_isolation_isolate_title
    case end_of_isolation_finished_description
    case end_of_isolation_positive_text_no_isolation_title
    case end_of_isolation_positive_text_no_isolation_header
    case end_of_isolation_isolate_if_have_symptom_warning
    case end_of_isolation_negative_test_result
    case end_of_isolation_explanation_1
    case end_of_isolation_explanation_negative_test_result
    case end_of_isolation_online_services_link
    case end_of_isolation_corona_back_to_home_button
    case end_of_isolation_further_advice_visit
    case end_of_isolation_link_label
    
    case positive_test_result_title
    case positive_test_result_info
    case positive_test_result_explanation
    case positive_test_results_continue
    case void_test_result_no_isolation_title
    case void_test_result_no_isolation_header
    case void_test_result_info
    case void_test_result_explanation
    case void_test_results_continue
    
    case negative_test_result_with_isolation_title
    case negative_test_result_with_isolation_info
    case negative_test_result_with_isolation_explanation
    case negative_test_result_with_isolation_advice
    case negative_test_result_with_isolation_service_link
    case negative_test_result_with_isolation_back_to_home
    case negative_test_result_after_positive_info
    case negative_test_result_after_positive_explanation
    case negative_test_result_after_positive_button_label
    case negative_test_result_no_isolation_title
    case negative_test_result_no_isolation_description
    case negative_test_result_no_isolation_warning
    case negative_test_result_no_isolation_link_hint
    case negative_test_result_no_isolation_link_label
    case negative_test_result_no_isolation_button_label
    
    case no_symptoms_heading
    case no_symptoms_body_1
    case no_symptoms_body_2
    case no_symptoms_link
    case no_symptoms_return_home_button
    
    case no_symptoms_isolating_info_isolate_for
    case no_symptoms_isolating_info
    case no_symptoms_isolating_body
    case no_symptoms_isolating_advice
    case no_symptoms_isolating_services_link
    case no_symptoms_isolating_return_home_button
    
    case isolation_until_date_title
    
    case symptom_review_title
    case symptom_review_heading
    case symptom_review_confirm_heading
    case symptom_review_deny_heading
    case symptom_review_date_heading
    case symptom_review_date_placeholder
    case symptom_review_date_hint
    case symptom_review_no_date
    case symptom_review_no_date_accessability_label_not_checked
    case symptom_review_no_date_accessability_label_checked
    case symptom_review_error_description
    case symptom_review_button_submit
    case symptom_review_button
    
    case virology_testing_information_title
    
    case virology_book_a_test_title
    case virology_book_a_test_heading
    case virology_book_a_test_paragraph1
    case virology_book_a_test_paragraph2
    case virology_book_a_test_paragraph3
    case virology_book_a_test_paragraph4
    case virology_book_a_test_testing_privacy_notice
    case virology_book_a_test_paragraph5
    case virology_book_a_test_app_privacy_notice
    case virology_book_a_test_paragraph6
    case virology_book_a_test_book_a_test_for_someone_else
    case virology_book_a_test_button
    
    case about_this_app_title
    case about_this_app_how_this_app_works_heading
    case about_this_app_how_this_app_works_paragraph1
    case about_this_app_how_this_app_works_paragraph2
    case about_this_app_how_this_app_works_paragraph3
    case about_this_app_how_this_app_works_instruction_for_use
    case about_this_app_how_this_app_works_button
    case about_this_app_common_questions_heading
    case about_this_app_common_questions_description
    case about_this_app_our_policies_heading
    case about_this_app_our_policies_description
    case about_this_app_our_policies_terms_of_use_button
    case about_this_app_our_policies_privacy_notice_button
    case about_this_app_our_policies_accessibility_statement_button
    case about_this_app_common_questions_button
    case about_this_app_my_data_heading
    case about_this_app_my_data_description
    case about_this_app_my_data_button
    case about_this_app_software_information_heading
    case about_this_app_software_information_app_name
    case about_this_app_software_information_version
    case about_this_app_software_information_date_of_release_title
    case about_this_app_software_information_date_of_release_description
    case about_this_app_software_information_manufacturer_title
    case about_this_app_software_information_manufacturer_description
    case about_this_app_feedback_information_title
    case about_this_app_feedback_information_description
    case about_this_app_feedback_information_link_title
    case about_this_app_footer_text
    
    case mydata_title
    case mydata_section_postcode_description
    case mydata_section_test_result_description
    case mydata_section_venue_history_description
    case mydata_section_symptoms_description
    case mydata_section_encounter_description
    case mydata_section_date_description
    case mydata_test_result_positive
    case mydata_test_result_negative
    case mydata_test_result_void
    case mydata_data_deletion_button_title
    case mydata_delete_data_alert_title
    case mydata_delete_data_alert_description
    case mydata_delete_data_alert_button_title
    case mydata_venue_history_edit_button_title
    case mydata_venue_history_done_button_title
    
    case accessability_error_os_out_of_date
    case accessability_error_update_the_app
    case accessability_error_cannot_run_app
    
    case link_privacy
    case link_our_policies
    case link_faq
    case link_about_the_app
    case link_accessibility_statement
    case link_isolation_advice
    case link_general_advice
    case link_more_info_on_postcode_risk
    case link_book_a_test_for_someone_else
    case link_testing_privacy_notice
    case link_nhs111_online
    case link_how_this_app_works
    case link_provide_feedback
    
    case cancel
    case back
    
    case exposure_notification_reminder_button
    case exposure_notification_reminder_title
    case exposure_notification_reminder_sheet_title
    case exposure_notification_reminder_sheet_description
    case exposure_notification_reminder_sheet_cancel
    case exposure_notification_reminder_alert_description
    case exposure_notification_reminder_alert_button
    
    case edit_postcode_title
    
    case age_confirmation_alert_title
    case age_confirmation_alert_body
    case age_confirmation_alert_accept
    case age_confirmation_alert_reject
    
    case below_required_age_title
    case below_required_age_description
    
    case edit_postcode_save_button
    
    case link_test_result_title
    case link_test_result_header
    case link_test_result_description
    case link_test_result_enter_code_heading
    case link_test_result_enter_code_example
    case link_test_result_enter_code_textfield_label
    case link_test_result_enter_code_invalid_error
    case link_test_result_button_title
    
    case checkin_confirmation_title
    
    case share_keys_confirmation_title
    case share_keys_confirmation_heading
    case share_keys_confirmation_info_title
    case share_keys_confirmation_info_body
    case share_keys_confirmation_i_understand
    case home_link_test_result_button_title
    
    case network_error_no_internet_connection
    case network_error_general
    
    case delete
    
    case qr_code_poster_description
    case qr_code_poster_description_wls
    case qr_code_poster_accessibility_label
    case qr_code_poster_accessibility_label_wls
    
    case positive_test_result_start_to_isolate_title
    case positive_test_result_start_to_isolate_info
    case positive_test_result_start_to_isolate_explaination
    
    case isolation_payment_info_title
    case isolation_payment_info_header
    case isolation_payment_info_description
    case isolation_payment_info_button
    
    case dont_worry_notification_title
    case dont_worry_notification_body
    
    case risky_venue_isolation_report_symptoms
    case risky_venue_isolation_warning
    case risky_venue_isolation_description
}

public enum ParameterisedStringLocalizable: Equatable {
    
    enum Key: String, CaseIterable {
        case numbered_list_item = "numbered_list_item %ld %@"
        case risk_level_banner_text = "risk_level_banner_text %@ %@"
        
        case checkin_confirmation_date = "checkin_confirmation_date %@"
        case checkin_camera_qrcode_scanner_help_button_title = "checkin_camera_qrcode_scanner_help_button_title %@"
        case checkin_risky_venue_information_title = "checkin_risky_venue_information_title %@ %@"
        
        case symptom_card_accessibility_label = "symptom_card_accessibility_label %@ %@"
        case symptom_card_checkbox_accessibility_label = "symptom_card_checkbox_accessibility_label %@ %@ %@"
        case symptom_onset_select_day = "symptom_onset_select_day %@"
        case step_accessibility_label = "step_accessibility_label %ld %ld"
        case step_label = "step_label %ld %ld"
        case isolation_days_subtitle = "isolation_days_subtitle %ld"
        case isolation_days_accessibility_label = "isolation_days_accessibility_label %ld"
        case isolation_until_date = "isolation_until_date %@ %@"
        case positive_symptoms_days = "positive_symptoms_days %ld"
        case positive_symptoms_please_isolate_accessibility_label = "positive_symptoms_please_isolate_accessibility_label %ld"
        case positive_test_please_isolate_accessibility_label = "positive_test_please_isolate_accessibility_label %ld"
        case end_of_isolation_has_passed_description = "end_of_isolation_has_passed_description date: %@ time: %@"
        case end_of_isolation_is_near_description = "end_of_isolation_is_near_description date: %@ time: %@"
        
        case exposure_acknowledgement_days = "exposure_acknowledgement_days %ld"
        case exposure_acknowledgement_please_isolate_accessibility_label = "exposure_acknowledgement_please_isolate_accessibility_label %ld"
        
        case mydata_date_description = "mydata_date_description %@"
        case mydata_date_interval_description = "mydata_date_interval_description %@ %@"
        
        case symptom_review_button_accessibility_label = "symptom_review_button_accessibility_label %@"
        
        case isolation_indicator_accessiblity_label = "isolation_indicator_accessiblity_label days: %ld date: %@ time: %@"
        
        case exposure_notification_reminder_sheet_hours = "%ld exposure_notification_reminder_sheet_hours"
        case exposure_notification_reminder_alert_title = "exposure_notification_reminder_alert_title %ld hours"
        
        case positive_test_start_to_isolate_accessibility_label = "positive_test_start_to_isolate_accessibility_label %ld"
        
        case risky_venue_isolation_title_accessibility = "risky_venue_isolation_title_accessibility %ld"
    }
    
    case numbered_list_item(index: Int, text: String)
    
    case checkin_confirmation_date(date: Date)
    case checkin_camera_qrcode_scanner_help_button_title
    case checkin_risky_venue_information_title(venue: String, date: Date)
    
    case risk_level_banner_text(postcode: String, risk: String)
    
    case isolation_days_subtitle(days: Int)
    case isolation_days_accessibility_label(days: Int)
    
    case isolation_until_date(date: Date)
    
    case isolation_indicator_accessiblity_label(date: Date, days: Int)
    
    case symptom_card_checkbox_accessibility_label(value: String, heading: String, content: String)
    case symptom_card_accessibility_label(heading: String, content: String)
    case symptom_onset_select_day(Date)
    
    case step_accessibility_label(index: Int, count: Int)
    case step_label(index: Int, count: Int)
    
    case positive_symptoms_days(days: Int)
    case positive_symptoms_please_isolate_accessibility_label(days: Int)
    case positive_test_please_isolate_accessibility_label(days: Int)
    
    case end_of_isolation_has_passed_description(at: Date)
    case end_of_isolation_is_near_description(at: Date)
    
    case exposure_acknowledgement_days(days: Int)
    case exposure_acknowledgement_please_isolate_accessibility_label(days: Int)
    
    case mydata_date_description(date: Date)
    case mydata_date_interval_description(startdate: Date, endDate: Date)
    
    case symptom_review_button_accessibility_label(symptom: String)
    
    case exposure_notification_reminder_sheet_hours(hours: Int)
    case exposure_notification_reminder_alert_title(hours: Int)
    
    case positive_test_start_to_isolate_accessibility_label(days: Int)
    
    case risky_venue_isolation_title_accessibility(days: Int)
    
    var key: Key {
        switch self {
        case .numbered_list_item: return .numbered_list_item
        case .risk_level_banner_text: return .risk_level_banner_text
        case .checkin_confirmation_date: return .checkin_confirmation_date
        case .checkin_risky_venue_information_title: return .checkin_risky_venue_information_title
        case .checkin_camera_qrcode_scanner_help_button_title: return .checkin_camera_qrcode_scanner_help_button_title
        case .symptom_card_accessibility_label: return .symptom_card_accessibility_label
        case .symptom_card_checkbox_accessibility_label: return .symptom_card_checkbox_accessibility_label
        case .symptom_onset_select_day: return .symptom_onset_select_day
        case .step_accessibility_label: return .step_accessibility_label
        case .step_label: return .step_label
        case .isolation_days_subtitle: return .isolation_days_subtitle
        case .isolation_days_accessibility_label: return .isolation_days_accessibility_label
        case .isolation_until_date: return .isolation_until_date
        case .positive_symptoms_days: return .positive_symptoms_days
        case .positive_symptoms_please_isolate_accessibility_label: return .positive_symptoms_please_isolate_accessibility_label
        case .positive_test_please_isolate_accessibility_label: return .positive_test_please_isolate_accessibility_label
        case .end_of_isolation_has_passed_description: return .end_of_isolation_has_passed_description
        case .end_of_isolation_is_near_description: return .end_of_isolation_is_near_description
            
        case .exposure_acknowledgement_days: return .exposure_acknowledgement_days
        case .exposure_acknowledgement_please_isolate_accessibility_label: return .exposure_acknowledgement_please_isolate_accessibility_label
            
        case .mydata_date_description: return .mydata_date_description
        case .mydata_date_interval_description: return .mydata_date_interval_description
            
        case .symptom_review_button_accessibility_label: return .symptom_review_button_accessibility_label
            
        case .isolation_indicator_accessiblity_label: return .isolation_indicator_accessiblity_label
        case .exposure_notification_reminder_sheet_hours: return .exposure_notification_reminder_sheet_hours
        case .exposure_notification_reminder_alert_title: return .exposure_notification_reminder_alert_title
        case .positive_test_start_to_isolate_accessibility_label: return .positive_test_start_to_isolate_accessibility_label
        case .risky_venue_isolation_title_accessibility: return .risky_venue_isolation_title_accessibility
        }
    }
    
    var arguments: [CVarArg] {
        switch self {
        case .numbered_list_item(let index, let text):
            return [index, text]
        case .risk_level_banner_text(let postcode, let risk):
            return [postcode, risk]
        case .checkin_confirmation_date(let date):
            return [
                DateFormatter.mediumDateShortTime.string(from: date),
            ]
        case .checkin_camera_qrcode_scanner_help_button_title:
            return ["\u{24D8}"]
        case .checkin_risky_venue_information_title(let venue, let date):
            return [
                venue,
                DateFormatter.mediumDateShortTime.string(from: date),
            ]
        case .symptom_card_accessibility_label(let heading, let content):
            return [heading, content]
        case .symptom_card_checkbox_accessibility_label(let value, let heading, let content):
            return [value, heading, content]
        case .symptom_onset_select_day(let date):
            return [
                DateFormatter.dayOfYearAllowRelative.string(from: date),
            ]
        case .step_accessibility_label(let index, let count):
            return [index, count]
        case .step_label(let index, let count):
            return [index, count]
        case .isolation_days_subtitle(let days):
            return [days]
        case .isolation_days_accessibility_label(let days):
            return [days]
        case .isolation_until_date(let date):
            return [
                DateFormatter.dayOfYear.string(from: date.advanced(by: -1)),
                DateFormatter.time.string(from: date.advanced(by: -1)),
            ]
        case .end_of_isolation_has_passed_description(let date),
             .end_of_isolation_is_near_description(let date):
            return [
                DateFormatter.dayOfYear.string(from: date.advanced(by: -1)),
                DateFormatter.time.string(from: date.advanced(by: -1)),
            ]
        case .isolation_indicator_accessiblity_label(let date, let days):
            return [
                days,
                DateFormatter.dayOfYear.string(from: date.advanced(by: -1)),
                DateFormatter.time.string(from: date.advanced(by: -1)),
            ]
        case .positive_symptoms_days(let days):
            return [days]
        case .positive_symptoms_please_isolate_accessibility_label(let days):
            return [days]
        case .positive_test_please_isolate_accessibility_label(let days):
            return [days]
            
        case .exposure_acknowledgement_days(let days):
            return [days]
        case .exposure_acknowledgement_please_isolate_accessibility_label(let days):
            return [days]
            
        case .mydata_date_description(let date):
            return [DateFormatter.dayOfYear.string(from: date)]
        case .mydata_date_interval_description(let startDate, let endDate):
            return [DateIntervalFormatter.dayOfYearInterval.string(from: startDate, to: endDate.advanced(by: -1))]
            
        case .symptom_review_button_accessibility_label(let symptom):
            return [symptom]
            
        case .exposure_notification_reminder_sheet_hours(let hours):
            return [hours]
        case .exposure_notification_reminder_alert_title(let hours):
            return [hours]
        case .positive_test_start_to_isolate_accessibility_label(days: let days):
            return [days]
        case .risky_venue_isolation_title_accessibility(days: let days):
            return [days]
        }
    }
    
}

#warning("Improve handling of language changes in formatters")
// When this module is used as part of a test (like UI tests) `Localization.bundle` may change at run time.
// When that happens, we should update the locale as well. `Localization.make` partly handles it, but we also need to
// regenerate the format by calling `setLocalizedDateFormatFromTemplate` again.
//
// For now, this is done by making the formatters that use it generate a new instance each time. This is functionally
// correct but inefficient.

private extension DateFormatter {
    
    // For formats, see: https://www.unicode.org/reports/tr35/tr35-dates.html#Date_Field_Symbol_Table
    static var dayOfYear: DateFormatter {
        let dateFormatter = Localization.make(DateFormatter.self)
        dateFormatter.setLocalizedDateFormatFromTemplate("yyyyMMMd")
        return dateFormatter
    }
    
    static let dayOfYearAllowRelative: DateFormatter = {
        let dateFormatter = Localization.make(DateFormatter.self)
        dateFormatter.timeStyle = .none
        dateFormatter.dateStyle = .medium
        dateFormatter.doesRelativeDateFormatting = true
        return dateFormatter
    }()
    
    static var monthOfYear: DateFormatter {
        let dateFormatter = Localization.make(DateFormatter.self)
        dateFormatter.setLocalizedDateFormatFromTemplate("yyyyLLL")
        return dateFormatter
    }
    
    static var time: DateFormatter {
        let dateFormatter = Localization.make(DateFormatter.self)
        dateFormatter.setLocalizedDateFormatFromTemplate("jjmm")
        return dateFormatter
    }
    
    static let mediumDateShortTime: DateFormatter = {
        let formatter = Localization.make(DateFormatter.self)
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}

private extension DateIntervalFormatter {
    static let dayOfYearInterval: DateIntervalFormatter = {
        let formatter = Localization.make(DateIntervalFormatter.self)
        formatter.dateStyle = .medium
        formatter.timeStyle = .short
        return formatter
    }()
}
