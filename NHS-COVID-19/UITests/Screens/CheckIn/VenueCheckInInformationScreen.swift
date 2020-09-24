//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import Scenarios
import XCTest

struct VenueCheckInInformationScreen {
    
    var app: XCUIApplication
    
    var screenTitle: XCUIElement {
        app.staticTexts[localized: .checkin_information_title_new]
    }
    
    var helpScanningTitle: XCUIElement {
        app.staticTexts[localized: .checkin_information_help_scanning_section_title]
    }
    
    var helpScanningDescription: XCUIElement {
        app.staticTexts[localized: .checkin_information_help_scanning_section_description]
    }
    
    var whatsAQRCodeTitle: XCUIElement {
        app.staticTexts[localized: .checkin_information_whats_a_qr_code_section_title]
    }
    
    var whatsAQRCodeDescription: XCUIElement {
        app.staticTexts[localized: .checkin_information_whats_a_qr_code_section_description_new]
    }
    
    var qrCodePosterDescription: XCUIElement {
        app.staticTexts[localized: .qr_code_poster_description]
    }
    
    var qrCodePosterImage: XCUIElement {
        app.images[localized: .qr_code_poster_accessibility_label]
    }
    
    var qrCodePosterDescriptionWLS: XCUIElement {
        app.staticTexts[localized: .qr_code_poster_description_wls]
    }
    
    var qrCodePosterImageWLS: XCUIElement {
        app.images[localized: .qr_code_poster_accessibility_label_wls]
    }
    
    var howItWorksTitle: XCUIElement {
        app.staticTexts[localized: .checkin_information_how_it_works_section_title]
    }
    
    var howItWorksDescription: XCUIElement {
        app.staticTexts[localized: .checkin_information_how_it_works_section_description]
    }
    
    var howItHelpsTitle: XCUIElement {
        app.staticTexts[localized: .checkin_information_how_it_helps_section_title]
    }
    
    var howItHelpsDescription: XCUIElement {
        app.staticTexts[localized: .checkin_information_how_it_helps_section_description]
    }
    
    var cancelButton: XCUIElement {
        app.buttons[localize(.cancel)]
    }
    
    var dismissAlert: XCUIElement {
        app.staticTexts[VenueCheckInInformationScreenScenario.didTapDismissAlertTitle]
    }
}
