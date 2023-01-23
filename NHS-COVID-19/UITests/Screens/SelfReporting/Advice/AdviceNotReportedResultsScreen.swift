//
// Copyright © 2022 DHSC. All rights reserved.
//

import Interface
import XCTest

struct AdviceNotReportedResultsScreen {
    let app: XCUIApplication

    var headerLabel: XCUIElement {
        app.staticTexts[localized: .self_report_advice_not_reported_result_header]
    }

    var subHeaderLabel: XCUIElement {
        app.staticTexts[localized: .self_report_advice_not_reported_result_header(days: 6, endDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())!)]
    }

    var infoSectionLink: XCUIElement {
        app.links[localized: .self_report_advice_info_section_url_label]
    }

    var infoSectionDescription: XCUIElement {
        app.staticTexts[localized: .self_report_advice_info_section_description]
    }

    var infoBox: XCUIElement {
        app.staticTexts[localized: .self_report_advice_information_label]
    }

    var bulletedListHeader: XCUIElement {
        app.staticTexts[localized: .self_report_advice_bulleted_list_header_label]
    }

    var iconBullet1Label: XCUIElement {
        app.staticTexts[localized: .self_report_advice_icon_bullet_1_label]
    }

    var iconBullet2Label: XCUIElement {
        app.staticTexts[localized: .self_report_advice_icon_bullet_2_label]
    }

    var iconBullet3Label: XCUIElement {
        app.staticTexts[localized: .self_report_advice_icon_bullet_3_label]
    }

    var readMoreLink: XCUIElement {
        app.links[localized: .self_report_advice_read_more_url_label]
    }

    var primaryLinkButton: XCUIElement {
        app.links[localized: .self_report_advice_primary_link_button_label]
    }

    var secondaryLinkButton: XCUIElement {
        app.buttons[localized: .back_to_home]
    }
}