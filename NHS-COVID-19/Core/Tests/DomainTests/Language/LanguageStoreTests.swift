//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Scenarios
import XCTest
@testable import Domain

class LanguageStoreTests: XCTestCase {
    private var encryptedStore: MockEncryptedStore!
    private var languageStore: LanguageStore!
    
    override func setUp() {
        super.setUp()
        
        encryptedStore = MockEncryptedStore()
        languageStore = LanguageStore(store: encryptedStore)
    }
    
    func testInitialConfigurationValue() {
        languageStore = LanguageStore(store: encryptedStore)
        XCTAssertEqual(languageStore.languageInfo.currentValue.configuration(supportedLocalizations: LocaleBundle().supportedLocalizations), .systemPreferred)
    }
    
    func testLoadingLanguageData() {
        encryptedStore.stored["language"] = #"""
        {
            "languageCode": "en"
        }
        """# .data(using: .utf8)!
        languageStore = LanguageStore(store: encryptedStore)
        XCTAssertEqual(languageStore.languageInfo.currentValue.configuration(supportedLocalizations: LocaleBundle().supportedLocalizations), .custom(localeIdentifier: "en"))
    }
    
    func testSaveLanguageSucess() throws {
        languageStore.save(localeConfiguration: .custom(localeIdentifier: "en"))
        XCTAssertEqual(languageStore.languageInfo.currentValue.configuration(supportedLocalizations: LocaleBundle().supportedLocalizations), .custom(localeIdentifier: "en"))
    }
    
    func testDeleteLanguage() throws {
        encryptedStore.stored["language"] = #"""
        {
            "languageCode": "en"
        }
        """# .data(using: .utf8)!
        languageStore = LanguageStore(store: encryptedStore)
        XCTAssertEqual(languageStore.languageInfo.currentValue.configuration(supportedLocalizations: LocaleBundle().supportedLocalizations), .custom(localeIdentifier: "en"))
        languageStore.delete()
        XCTAssertEqual(languageStore.languageInfo.currentValue.configuration(supportedLocalizations: LocaleBundle().supportedLocalizations), .systemPreferred)
    }
}

private class LocaleBundle: Bundle {
    override var localizations: [String] {
        return ["Base", "en"]
    }
}
