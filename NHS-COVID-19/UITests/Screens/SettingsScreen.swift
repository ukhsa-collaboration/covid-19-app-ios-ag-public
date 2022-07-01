//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import XCTest

struct SettingsScreen {
    var app: XCUIApplication

    var title: XCUIElement {
        app.staticTexts[localized: .settings_title]
    }

    var languageRow: XCUIElement {
        app.cells[localized: .settings_row_language]
    }

    var myAreaRow: XCUIElement {
        app.staticTexts[localized: .settings_row_my_area_title]
    }

    var myDataRow: XCUIElement {
        app.staticTexts[localized: .settings_row_my_data_title]
    }

    var venueHistoryRow: XCUIElement {
        app.staticTexts[localized: .settings_venue_history]
    }

    var deleteDataButton: XCUIElement {
        app.buttons[localized: .mydata_delete_and_reset_data_button_title]
    }

    var deleteDataAlert: XCUIElement {
        app.buttons[localized: .mydata_delete_data_alert_title]
    }

    var deleteDataAlertConfirmationButton: XCUIElement {
        app.buttons[localized: .mydata_delete_data_alert_button_title]
    }
}
