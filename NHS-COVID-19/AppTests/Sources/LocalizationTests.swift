//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import XCTest
@testable import Localization

class LocalizationTests: XCTestCase {
    
    func testAllLocalizationKeysHaveValue() {
        StringLocalizationKey.allCases.forEach {
            XCTAssert(Localization.hasLocalizedValue(for: $0), "No localized value for “\($0.rawValue)”")
            XCTAssertFalse(localize($0).containsForbiddenCharacters, "Using forbidden characters in localization of “\($0.rawValue)”")
        }
        ParameterisedStringLocalizable.Key.allCases.forEach {
            XCTAssert(Localization.hasLocalizedValue(for: $0), "No localized value for “\($0.rawValue)”")
            XCTAssertFalse(Localization.localize($0).containsForbiddenCharacters, "Using forbidden characters in localization of “\($0.rawValue)”")
        }
    }
    
}

private extension String {
    
    var containsForbiddenCharacters: Bool {
        rangeOfCharacter(from: .forbidden) != nil
    }
    
}

private extension CharacterSet {
    
    // ' and " are not allowed. Ensure you use the correct character, for example ‘ or ’
    static let forbidden = CharacterSet(charactersIn: #"'""#)
    
}
