//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import XCTest

extension XCUIElementQuery {
    
    subscript(localized key: StringLocalizationKey) -> XCUIElement {
        elementWithText(localize(key))
    }
    
    subscript(localized key: ParameterisedStringLocalizable) -> XCUIElement {
        elementWithText(localize(key))
    }
    
    subscript(verbatim string: String) -> XCUIElement {
        elementWithText(string)
    }
    
    subscript<T: RawRepresentable>(key key: T) -> XCUIElement where T.RawValue == String {
        elementWithText(key.rawValue)
    }
    
    private func elementWithText(_ string: String) -> XCUIElement {
        if string.count < 128 {
            return self[string]
        } else {
            // XCUITest can not correctly match long labels.
            return element(matching: NSPredicate(format: "label BEGINSWITH %@", String(string.prefix(128))))
        }
    }
    
}
