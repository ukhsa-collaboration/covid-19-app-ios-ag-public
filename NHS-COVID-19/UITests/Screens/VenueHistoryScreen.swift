//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import XCTest

struct VenueHistoryScreen {
    var app: XCUIApplication

    var title: XCUIElement {
        app.staticTexts[localized: .settings_venue_history]
    }

    var noRecordsYetLabel: XCUIElement {
        app.staticTexts[localized: .settings_no_records]
    }

    var editVenueHistoryButton: XCUIElement {
        app.buttons[localized: .mydata_venue_history_edit_button_title]
    }

    var doneVenueHistoryButton: XCUIElement {
        app.buttons[localized: .mydata_venue_history_done_button_title]
    }

    var cellDeleteButton: XCUIElement {
        app.tables.buttons[localized: .delete]
    }

    func dateHeader(_ date: Date) -> XCUIElement {
        app.staticTexts[localized: .venue_history_heading_accessibility_label(date: date)]
    }

    func cellPostcodeLabel(_ venuePostcode: String?) -> XCUIElement {
        app.staticTexts[venuePostcode ?? localize(.venue_history_postcode_unavailable)]
    }

    func checkInCell() -> XCUIElement {
        app.cells.element(boundBy: 0)
    }
}
