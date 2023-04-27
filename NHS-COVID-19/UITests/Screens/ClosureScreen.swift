//
// Copyright © 2023 DHSC. All rights reserved.
//
import Interface
import XCTest

struct ClosureScreen {
    let app: XCUIApplication

    var heading: XCUIElement {
        app.staticTexts[localized: .closure_title]
    }

    var body: XCUIElement {
        app.staticTexts[localized: .closure_paragraph]
    }

    var linkButtonOne: XCUIElement {
        app.links.element(containing: localize(.closure_url_1_label))
    }

    var linkButtonTwo: XCUIElement {
        app.links.element(containing: localize(.closure_url_2_label))
    }

    var linkButtonThree: XCUIElement {
        app.links.element(containing: localize(.closure_url_3_label))
    }

    var linkButtonFour: XCUIElement {
        app.links.element(containing: localize(.closure_url_4_label))
    }

    var linkButtonFive: XCUIElement {
        app.links.element(containing: localize(.closure_url_5_label))
    }

}
