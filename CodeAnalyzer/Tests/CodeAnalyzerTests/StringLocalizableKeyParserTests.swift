//
// Copyright © 2021 DHSC. All rights reserved.
//

import XCTest
@testable import CodeAnalyzer

final class StringLocalizableKeyParserTests: XCTestCase {
    private var stringLocalizationParser: StringLocalizableKeyParser!

    override func setUpWithError() throws {
        try super.setUpWithError()

        stringLocalizationParser = try StringLocalizableKeyParser(
            file: MockFile.StringLocalizableKey.url
        )
    }

    func testKeys() {

        let expectedDefaultKeys: Set<String> = [
            "onboarding_strapline_title",
            "home_strapline_title",
            "home_strapline_accessiblity_label",
            "onboarding_strapline_accessiblity_label",
            "home_strapline_accessiblity_label_wls",
            "onboarding_strapline_title",
        ]

        let expectedParameterizedKeys: Set<StringLocalizableKeyParser.ParameterizedKey> = [
            StringLocalizableKeyParser.ParameterizedKey(
                identifier: "numbered_list_item",
                rawValue: "numbered_list_item %ld %@"
            ),
            StringLocalizableKeyParser.ParameterizedKey(
                identifier: "risk_level_banner_text",
                rawValue: "risk_level_banner_text %@ %@"
            ),
            StringLocalizableKeyParser.ParameterizedKey(
                identifier: "checkin_confirmation_date",
                rawValue: "checkin_confirmation_date %@"
            ),
        ]

        XCTAssertEqual(expectedDefaultKeys, stringLocalizationParser.defaultKeys)

        XCTAssertEqual(expectedParameterizedKeys, stringLocalizationParser.parameterizedKeys)
    }
}
