//
// Copyright © 2020 NHSX. All rights reserved.
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
        XCTAssertEqual(languageStore.languageCode, nil)
    }
    
    func testLoadingLanguageData() {
        encryptedStore.stored["language"] = #"""
        {
            "languageCode": "en"
        }
        """# .data(using: .utf8)!
        languageStore = LanguageStore(store: encryptedStore)
        XCTAssertEqual(languageStore.languageCode, "en")
    }
    
    func testSaveLanguageSucess() throws {
        languageStore.save(localeConfiguration: .custom(localeIdentifier: "en"))
        XCTAssertEqual(languageStore.languageCode, "en")
    }
    
    func testDeleteLanguage() throws {
        encryptedStore.stored["language"] = #"""
        {
            "languageCode": "en"
        }
        """# .data(using: .utf8)!
        languageStore = LanguageStore(store: encryptedStore)
        XCTAssertEqual(languageStore.languageCode, "en")
        languageStore.delete()
        XCTAssertNil(languageStore.languageCode)
    }
}
