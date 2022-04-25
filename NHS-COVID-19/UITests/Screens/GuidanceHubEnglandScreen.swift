//
// Copyright © 2022 DHSC. All rights reserved.
//
import Interface
import XCTest

struct GuidanceHubEnglandScreen {
    let app: XCUIApplication
    
    var covidGuidanceForEnglandButton: XCUIElement {
        app.buttons.element(containing: localize(.covid_guidance_hub_for_england_title))
    }
    
    var checkSymptomsButton: XCUIElement {
        app.buttons.element(containing: localize(.covid_guidance_hub_check_symptoms_title))
    }
    
    var latestGuidanceButton: XCUIElement {
        app.buttons.element(containing: localize(.covid_guidance_hub_latest_title))
    }
    
    var positiveTestResultButton: XCUIElement {
        app.buttons.element(containing: localize(.covid_guidance_hub_positive_test_result_title))
    }
    
    var travellingAbroadButton: XCUIElement {
        app.buttons.element(containing: localize(.covid_guidance_hub_travelling_abroad_title))
    }
    
    var checkSSPButton: XCUIElement {
        app.buttons.element(containing: localize(.covid_guidance_hub_check_ssp_title))
    }
    
    var covidEnquiriesButton: XCUIElement {
        app.buttons.element(containing: localize(.covid_guidance_hub_covid_enquiries_title))
    }
}
