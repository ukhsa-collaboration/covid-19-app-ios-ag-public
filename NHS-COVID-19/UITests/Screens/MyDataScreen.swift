//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import XCTest

struct MyDataScreen {
    
    var app: XCUIApplication
    
    var title: XCUIElement {
        app.staticTexts[localized: .mydata_title]
    }
    
    var deleteDataButton: XCUIElement {
        app.buttons[localized: .mydata_data_deletion_button_title]
    }
}
