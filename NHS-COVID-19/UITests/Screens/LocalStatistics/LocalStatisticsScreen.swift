//
// Copyright © 2021 DHSC. All rights reserved.
//

import Interface
import XCTest

struct LocalStatisticsScreen {
    let app: XCUIApplication

    var navigationTitle: XCUIElement {
        app.staticTexts[localized: .local_statistics_main_screen_navigation_title]
    }

    var title: XCUIElement {
        app.staticTexts[localized: .local_statistics_main_screen_title]
    }

    var generalInfo: XCUIElement {
        app.staticTexts[localized: .local_statistics_main_screen_info]
    }

    func lastUpdated(date: Date) -> XCUIElement {
        return app.staticTexts[localized: .local_statistics_main_screen_last_updated(date: date)]
    }

    var moreInfo: XCUIElement {
        app.staticTexts[localized: .local_statistics_main_screen_more_info]
    }

    var dashboardLink: XCUIElement {
        app.links[localized: .local_statistics_main_screen_dashboard_link_title]
    }

}
