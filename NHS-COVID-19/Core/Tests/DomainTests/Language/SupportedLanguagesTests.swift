//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation
import Localization
import XCTest

class SupportedLanguagesTests: XCTestCase {
    
    func testSupportedLanguageWithExistingLanguageCode() {
        XCTAssertFalse(SupportedLanguage.allLanguages(currentLocaleIdentifier: "en").contains(nil))
    }
}
