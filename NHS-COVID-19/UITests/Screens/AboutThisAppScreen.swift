//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest

struct AboutThisAppScreen {
    var app: XCUIApplication
    
    var aboutThisAppHeadingLabel: XCUIElement {
        app.staticTexts[localized: .about_this_app_how_this_app_works_heading]
    }
    
    var aboutThisAppParagraphOne: XCUIElement {
        app.staticTexts[localized: .about_this_app_how_this_app_works_paragraph1]
    }
    
    var aboutThisAppParagraphTwo: XCUIElement {
        app.staticTexts[localized: .about_this_app_how_this_app_works_paragraph2]
    }
    
    var aboutThisAppParagraphThree: XCUIElement {
        app.staticTexts[localized: .about_this_app_how_this_app_works_paragraph3]
    }
    
    var aboutThisAppButton: XCUIElement {
        app.links[localized: .about_this_app_how_this_app_works_button]
    }
    
    var commonQuestionsHeading: XCUIElement {
        app.staticTexts[localized: .about_this_app_common_questions_heading]
    }
    
    var commonQuestionsDescription: XCUIElement {
        app.staticTexts[localized: .about_this_app_common_questions_description]
    }
    
    var commonQuestionsButton: XCUIElement {
        app.links[localized: .about_this_app_common_questions_button]
    }
    
    var ourPoliciesHeading: XCUIElement {
        app.staticTexts[localized: .about_this_app_our_policies_heading]
    }
    
    var ourPoliciesDescription: XCUIElement {
        app.staticTexts[localized: .about_this_app_our_policies_description]
    }
    
    var termsOfUseButton: XCUIElement {
        app.links[localized: .about_this_app_our_policies_terms_of_use_button]
    }
    
    var privacyNoticeButton: XCUIElement {
        app.links[localized: .about_this_app_our_policies_privacy_notice_button]
    }
    
    var accessibilityStatementButton: XCUIElement {
        app.links[localized: .about_this_app_our_policies_accessibility_statement_button]
    }
    
    var showMyDataHeading: XCUIElement {
        app.staticTexts[localized: .about_this_app_my_data_heading]
    }
    
    var showMyDataDescription: XCUIElement {
        app.staticTexts[localized: .about_this_app_my_data_description]
    }
    
    var seeDataButton: XCUIElement {
        app.links[localized: .about_this_app_my_data_button]
    }
    
    var softwareInformationHeading: XCUIElement {
        app.staticTexts[localized: .about_this_app_software_information_heading]
    }
    
    var aboutThisAppFooterText: XCUIElement {
        app.staticTexts[localized: .about_this_app_footer_text]
    }
    
    var appName: XCUIElement {
        app.staticTexts[localized: .about_this_app_software_information_app_name(name: AboutThisAppScreenScenario.appName)]
    }
    
    var version: XCUIElement {
        app.staticTexts[localized: .about_this_app_software_information_version(version: AboutThisAppScreenScenario.version)]
    }
    
    var dateOfRelease: XCUIElement {
        app.staticTexts[localized: .about_this_app_software_information_date_of_release]
    }
    
    var entityNameAndAddress: XCUIElement {
        app.staticTexts[localized: .about_this_app_software_information_entity_name_and_address]
    }
    
}
