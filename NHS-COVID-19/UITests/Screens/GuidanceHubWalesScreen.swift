//
// Copyright © 2022 DHSC. All rights reserved.
//
import Interface
import XCTest

struct GuidanceHubWalesScreen {
    let app: XCUIApplication

    var allElements: [XCUIElement] {
        [
            linkButtonOne,
            linkButtonTwo,
            linkButtonThree,
            linkButtonFour,
            linkButtonFive,
            linkButtonSix,
            linkButtonSeven
        ]
    }

    var linkButtonOne: XCUIElement {
        app.links.element(containing: localize(.covid_guidance_hub_wales_button_one_title))
    }

    var linkButtonTwo: XCUIElement {
        app.links.element(containing: localize(.covid_guidance_hub_wales_button_two_title))
    }

    var linkButtonThree: XCUIElement {
        app.links.element(containing: localize(.covid_guidance_hub_wales_button_three_title))
    }

    var linkButtonFour: XCUIElement {
        app.links.element(containing: localize(.covid_guidance_hub_wales_button_four_title))
    }

    var linkButtonFive: XCUIElement {
        app.links.element(containing: localize(.covid_guidance_hub_wales_button_five_title))
    }

    var linkButtonSix: XCUIElement {
        app.links.element(containing: localize(.covid_guidance_hub_wales_button_six_title))
    }

    var linkButtonSeven: XCUIElement {
        app.links.element(containing: localize(.covid_guidance_hub_wales_button_seven_title))
    }

}
