//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation
import XCTest
@testable import Localization

class PreferredLocaleIdentifierTests: XCTestCase {
    override class func tearDown() {
        LocaleConfiguration.systemPreferred.becomeCurrent()
    }
    
    func testInitialValue() throws {
        XCTAssertEqual(Localization.preferredLocaleIdentifier(from: []), "en")
    }
    
    func testValidLocaleWithMatchingDevelopmentLanguage() throws {
        XCTAssertEqual(Localization.preferredLocaleIdentifier(from: ["en-GB"]), "en-GB")
    }
    
    func testValidCustomLocale() throws {
        LocaleConfiguration.custom(localeIdentifier: "ar").becomeCurrent()
        XCTAssertEqual(Localization.preferredLocaleIdentifier(from: ["en", "ar", "cy"]), "ar")
    }
    
    func testInvalidCustomLocale() throws {
        LocaleConfiguration.custom(localeIdentifier: "ar").becomeCurrent()
        XCTAssertEqual(Localization.preferredLocaleIdentifier(from: []), "en")
    }
    
    func testValidCustomLocaleByLookup() throws {
        LocaleConfiguration.custom(localeIdentifier: "ar").becomeCurrent()
        XCTAssertEqual(Localization.preferredLocaleIdentifier(from: ["en-GB", "ar-GB", "cy-GB"]), "ar-GB")
    }
    
    func testValidCustomUnderscoreLocaleByLookup() throws {
        LocaleConfiguration.custom(localeIdentifier: "ar").becomeCurrent()
        XCTAssertEqual(Localization.preferredLocaleIdentifier(from: ["en_GB", "ar_GB", "cy_GB"]), "ar_GB")
    }
    
    func testValidCustomInvertedDashLocaleByLookup() throws {
        LocaleConfiguration.custom(localeIdentifier: "ar-GB").becomeCurrent()
        XCTAssertEqual(Localization.preferredLocaleIdentifier(from: ["en", "ar", "cy"]), "ar")
    }
    
    func testValidCustomInvertedUnderscoreLocaleByLookup() throws {
        LocaleConfiguration.custom(localeIdentifier: "ar_GB").becomeCurrent()
        XCTAssertEqual(Localization.preferredLocaleIdentifier(from: ["en", "ar", "cy"]), "ar")
    }
    
    func testValidCustomLocaleWithUnderscoreAndDash() throws {
        LocaleConfiguration.custom(localeIdentifier: "ar_GB").becomeCurrent()
        XCTAssertEqual(Localization.preferredLocaleIdentifier(from: ["ar", "ar-GB"]), "ar-GB")
    }
    
    func testValidCustomLocaleWithNoMatchingValues() throws {
        LocaleConfiguration.custom(localeIdentifier: "ar").becomeCurrent()
        XCTAssertEqual(Localization.preferredLocaleIdentifier(from: ["en-GB", "fr"]), "en-GB")
    }
}
