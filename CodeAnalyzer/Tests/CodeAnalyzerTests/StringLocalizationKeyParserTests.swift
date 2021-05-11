//
// Copyright © 2021 DHSC. All rights reserved.
//

import XCTest
@testable import CodeAnalyzer

final class StringLocalizationKeyParserTests: XCTestCase {
    private var stringLocalizationParser: StringLocalizationKeyParser!
    
    override func setUpWithError() throws {
        try super.setUpWithError()
        
        stringLocalizationParser = try StringLocalizationKeyParser(
            file: MockFile.stringLocalizationKey.url
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
        
        let expectedParameterizedKeys: Set<StringLocalizationKeyParser.ParameterizedKey> = [
            StringLocalizationKeyParser.ParameterizedKey(
                identifier: "numbered_list_item",
                rawValue: "numbered_list_item %ld %@"
            ),
            StringLocalizationKeyParser.ParameterizedKey(
                identifier: "risk_level_banner_text",
                rawValue: "risk_level_banner_text %@ %@"
            ),
            StringLocalizationKeyParser.ParameterizedKey(
                identifier: "checkin_confirmation_date",
                rawValue: "checkin_confirmation_date %@"
            ),
        ]
        
        XCTAssertEqual(expectedDefaultKeys, stringLocalizationParser.defaultKeys)
        
        XCTAssertEqual(expectedParameterizedKeys, stringLocalizationParser.parameterizedKeys)
    }
}
