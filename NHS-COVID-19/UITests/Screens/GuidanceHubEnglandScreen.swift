//
// Copyright © 2022 DHSC. All rights reserved.
//
import Interface
import XCTest

struct GuidanceHubEnglandScreen {
    let app: XCUIApplication

    var linkButtonOneEngland: XCUIElement {
        app.buttons.element(containing: localize(.covid_guidance_hub_england_button_one_title))
    }

    var linkButtonTwoEngland: XCUIElement {
        app.buttons.element(containing: localize(.covid_guidance_hub_england_button_two_title))
    }

    var linkButtonThreeEngland: XCUIElement {
        app.buttons.element(containing: localize(.covid_guidance_hub_england_button_three_title))
    }

    var linkButtonFourEngland: XCUIElement {
        app.buttons.element(containing: localize(.covid_guidance_hub_england_button_four_title))
    }

    var linkButtonFiveEngland: XCUIElement {
        app.buttons.element(containing: localize(.covid_guidance_hub_england_button_five_title))
    }

    var linkButtonSixEngland: XCUIElement {
        app.buttons.element(containing: localize(.covid_guidance_hub_england_button_six_title))
    }

    var linkButtonSevenEngland: XCUIElement {
        app.buttons.element(containing: localize(.covid_guidance_hub_england_button_seven_title))
    }

    var linkButtonEightEngland: XCUIElement {
        app.buttons.element(containing: localize(.covid_guidance_hub_england_button_eight_title))
    }

}
