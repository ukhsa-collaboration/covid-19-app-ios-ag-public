//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import XCTest
@testable import Common

public class LocaleConfigurationTests: XCTestCase {
    func testSystemPreferred() {
        let localeConfiguration = LocaleConfiguration(localeIdentifier: nil, supportedLocalizations: LocaleBundle().supportedLocalizations)
        XCTAssertEqual(localeConfiguration, .systemPreferred)
    }
    
    func testBaseLocale() {
        let localizations = LocaleBundle().localizations
        XCTAssertTrue(localizations.contains("Base"))
        let localeConfiguration = LocaleConfiguration(localeIdentifier: "Base", supportedLocalizations: LocaleBundle().supportedLocalizations)
        XCTAssertEqual(localeConfiguration, .systemPreferred)
    }
    
    func testCustomLocale() {
        let localeConfiguration = LocaleConfiguration(localeIdentifier: "en", supportedLocalizations: LocaleBundle().supportedLocalizations)
        XCTAssertEqual(localeConfiguration, .custom(localeIdentifier: "en"))
    }
    
    func testInvalidCustomLocale() {
        let localeConfiguration = LocaleConfiguration(localeIdentifier: "ar", supportedLocalizations: LocaleBundle().supportedLocalizations)
        XCTAssertEqual(localeConfiguration, .systemPreferred)
    }
}

private class LocaleBundle: Bundle {
    override var localizations: [String] {
        return ["Base", "en"]
    }
}
