//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import Scenarios
import XCTest

struct SelectLocalAuthorityScreen {
    var app: XCUIApplication

    var title: XCUIElement {
        app.staticTexts[localized: .local_authority_information_title]
    }

    func description(postcode: String) -> XCUIElement {
        return app.staticTexts[localized: .local_authority_screen_description(postcode: postcode)]
    }

    var noSelectionError: XCUIElement {
        app.staticTexts[localized: .symptom_card_accessibility_label(heading: localize(.local_authority_error_title), content: localize(.local_authority_error_description))]
    }

    var unsupportedCountryError: XCUIElement {
        app.staticTexts[localized: .symptom_card_accessibility_label(heading: localize(.local_authority_unsupported_country_error_title), content: localize(.local_authority_unsupported_country_error_description))]
    }

    func localAuthorityCard(checked: Bool, title: String) -> XCUIElement {
        let value = checked ? localize(.symptom_card_checked) : localize(.symptom_card_unchecked)
        return app.buttons[localized: .local_authority_card_checkbox_accessibility_label(value: value, content: title)]
    }

    var linkBtn: XCUIElement {
        app.links[localized: .local_authority_visit_gov_uk_link_title]
    }

    var button: XCUIElement {
        app.buttons[localized: .local_authority_confirmation_button]
    }
}
