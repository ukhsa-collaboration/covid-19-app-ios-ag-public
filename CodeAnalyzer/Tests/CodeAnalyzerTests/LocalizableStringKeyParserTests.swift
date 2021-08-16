//
// Copyright © 2021 DHSC. All rights reserved.
//

import XCTest
@testable import CodeAnalyzer

final class LocalizableStringKeyParserTests: XCTestCase {
    private var localizableStringKeyParser: LocalizableStringKeyParser!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        try localizableStringKeyParser = LocalizableStringKeyParser(file: MockFile.localizableString.url)
    }
    
    func testKeys() {
        let expected: Set<LocalizableKey> = [
            LocalizableKey(
                key: "key_one",
                keyWithSuffix: "key_one_wls"
            ),
            LocalizableKey(
                key: "key_one_%@",
                keyWithSuffix: nil
            ),
        ]
        
        XCTAssertEqual(localizableStringKeyParser.keys, expected)
    }
}

// MARK: - Helper methods

enum MockFile {
    case StringLocalizableKey
    case localizableString
    case localizableStringDict
    case swiftFileUsingKeys
    
    var url: URL {
        let resourceFilesDirectory = URL(fileURLWithPath: #file).deletingLastPathComponent().appendingPathComponent("ResourceFiles")
        
        switch self {
        case .StringLocalizableKey:
            return resourceFilesDirectory.appendingPathComponent("StringLocalizableKey.swift")
        case .localizableString:
            return resourceFilesDirectory.appendingPathComponent("Localizable.strings")
        case .localizableStringDict:
            return resourceFilesDirectory.appendingPathComponent("Localizable.stringsdict")
            
        case .swiftFileUsingKeys:
            return resourceFilesDirectory.appendingPathComponent("SwiftFileUsingLocalizableKeys.swift")
        }
    }
}
