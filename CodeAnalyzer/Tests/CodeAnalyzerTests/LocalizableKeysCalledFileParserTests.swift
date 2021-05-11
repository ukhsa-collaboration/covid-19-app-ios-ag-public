//
// Copyright © 2021 DHSC. All rights reserved.
//

import XCTest
@testable import CodeAnalyzer

final class LocalizableKeysCalledFileParserTests: XCTestCase {
    
    func testCalledKeys() throws {
        
        let definedKeys: Set<String> = [
            "settings_language_title",
            "settings_language_confirm_selection_alert_description",
            "settings_language_confirm_selection_alert_yes",
            "settings_language_system_language",
            "settings_language_override_languages",
        ]
        
        let localizableKeysCalledFileParser = try LocalizableKeysCalledFileParser(
            files: [MockFile.swiftFileUsingKeys.url], definedKeys: definedKeys
        )
        
        let expectedKeys: Set<String> = [
            "settings_language_title",
            "settings_language_confirm_selection_alert_description",
            "settings_language_confirm_selection_alert_yes",
            "settings_language_system_language",
            "settings_language_override_languages",
        ]
        
        XCTAssertEqual(expectedKeys, localizableKeysCalledFileParser.keys)
    }
    
    func testKeysUsedInTwoFiles() throws {
        let sourceFile1 = """
        //localize(.someKey)
        localize(.someKey)
        """
        let sourceFile2 = """
        //localize(.someKey2)
        localize(.someKey2)
        localize(.someKey3(label: someKey)
        """
        
        let parser = try LocalizableKeysCalledFileParser(source: [sourceFile1, sourceFile2], definedKeys: ["someKey", "someKey2", "someKey3"])
        
        XCTAssertEqual(Set<String>(["someKey", "someKey2", "someKey3"]), parser.keys)
    }
    
    func testDefinedKeysBeingUsed() throws {
        let sourceFile1 = """
        //localize(.someKey)
        //localizeAndSplit(.someKey1)
        //localizeURL(.someKey2)
        //localizeForCountry(.someKey3)
        //localizeForCountryAndSplit(.someKey4)
        init(argOne: "value", key: .one)
        bla("value", key: .one1)
        """
        
        let parser = try LocalizableKeysCalledFileParser(source: [sourceFile1], definedKeys: ["one", "one1", "two", "three"])
        
        XCTAssertEqual(["one", "one1"], parser.keys)
    }
    
}
