//
// Copyright © 2022 DHSC. All rights reserved.
//
import Interface
import XCTest

struct GuidanceHubWalesScreen {
    let app: XCUIApplication

    var allElements: [XCUIElement] {
        [
            linkButtonOneWales,
            linkButtonTwoWales,
            linkButtonThreeWales,
            linkButtonFourWales,
            linkButtonFiveWales,
            linkButtonSixWales,
            linkButtonSevenWales
        ]
    }

    var linkButtonOneWales: XCUIElement {
        app.links.element(containing: localize(.covid_guidance_hub_wales_button_one_title))
    }

    var linkButtonTwoWales: XCUIElement {
        app.links.element(containing: localize(.covid_guidance_hub_wales_button_two_title))
    }

    var linkButtonThreeWales: XCUIElement {
        app.links.element(containing: localize(.covid_guidance_hub_wales_button_three_title))
    }

    var linkButtonFourWales: XCUIElement {
        app.links.element(containing: localize(.covid_guidance_hub_wales_button_four_title))
    }

    var linkButtonFiveWales: XCUIElement {
        app.links.element(containing: localize(.covid_guidance_hub_wales_button_five_title))
    }

    var linkButtonSixWales: XCUIElement {
        app.links.element(containing: localize(.covid_guidance_hub_wales_button_six_title))
    }

    var linkButtonSevenWales: XCUIElement {
        app.links.element(containing: localize(.covid_guidance_hub_wales_button_seven_title))
    }

    var linkButtonEightWales: XCUIElement {
        app.links.element(containing: localize(.covid_guidance_hub_wales_button_eight_title))
    }

}
