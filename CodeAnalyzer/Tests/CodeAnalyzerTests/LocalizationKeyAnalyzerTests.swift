//
// Copyright © 2021 DHSC. All rights reserved.
//

import XCTest
@testable import CodeAnalyzer

final class LocalizationKeyAnalyzerTests: XCTestCase {
    private var analyzer: LocalizationKeyAnalyzer!

    override func setUpWithError() throws {
        try super.setUpWithError()

        analyzer = LocalizationKeyAnalyzer(
            localisationKeyParser: MockAppKeys(),
            localizableStringKeyParser: MockStringsKeys(),
            localizableStringDictKeyParser: MockStringsDictKeys(),
            localizationKeysCalledFileParser: MockKeysCalledFile()
        )
    }

    func testUndefinedKeys() {
        let expectedKeys: Set<LocalizableKey> = [
            LocalizableKey(
                key: "key_five %ld %ld",
                keyWithSuffix: "key_five %ld %ld_wls"
            ),
        ]
        XCTAssertEqual(expectedKeys, analyzer.undefinedKeys)
    }

    func testUncalledKeys() {

        let expectedKeys: Set<LocalizableKey> = [
            LocalizableKey(
                key: "key_two",
                keyWithSuffix: "key_two_wls"
            ),
            LocalizableKey(
                key: "key_three",
                keyWithSuffix: "key_three_wls"
            ),
            LocalizableKey(
                key: "key_four_%ld",
                keyWithSuffix: nil
            ),

        ]

        XCTAssertEqual(expectedKeys, analyzer.uncalledKeys)
    }
}

struct MockAppKeys: DefinedLocalizationKeys {
    var defaultKeys: Set<String> {
        ["key_one", "key_two", "key_three"]
    }

    var parameterizedKeys: Set<StringLocalizableKeyParser.ParameterizedKey> {
        [
            StringLocalizableKeyParser.ParameterizedKey(
                identifier: "key_four",
                rawValue: "key_four_%ld"
            ),
        ]
    }
}

struct MockStringsKeys: LocalizableKeys {
    var keys: Set<LocalizableKey> {
        [
            LocalizableKey(
                key: "key_one",
                keyWithSuffix: nil
            ),
            LocalizableKey(
                key: "key_two",
                keyWithSuffix: "key_two_wls"
            ),
            LocalizableKey(
                key: "key_three",
                keyWithSuffix: "key_three_wls"
            ),
            LocalizableKey(
                key: "key_four_%ld",
                keyWithSuffix: nil
            ),
            LocalizableKey(
                key: "key_five %ld %ld",
                keyWithSuffix: "key_five %ld %ld_wls"
            ),
        ]
    }
}

struct MockStringsDictKeys: LocalizableKeys {
    var keys: Set<LocalizableKey> {
        [
            LocalizableKey(
                key: "key_eight_%@",
                keyWithSuffix: nil
            ),
        ]
    }
}

struct MockKeysCalledFile: UsedLocalizationKeys {
    var keys: Set<String> = ["key_one"]
}
