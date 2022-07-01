//
// Copyright © 2021 DHSC. All rights reserved.
//

import XCTest
@testable import CodeAnalyzer

final class LocalizableStringDictParserTests: XCTestCase {
    private var parser: LocalizableStringDictParser!

    override func setUpWithError() throws {
        try super.setUpWithError()

        parser = try LocalizableStringDictParser(
            file: MockFile.localizableStringDict.url
        )
    }

    func testKeys() {

        let expectedSet: Set<LocalizableKey> = [
            LocalizableKey(
                key: "%ld exposure_notification_reminder_sheet_hours",
                keyWithSuffix: nil
            ),
            LocalizableKey(
                key: "exposure_notification_reminder_alert_title %ld hours",
                keyWithSuffix: nil
            ),
            LocalizableKey(
                key: "positive_test_please_isolate_accessibility_label %ld",
                keyWithSuffix: nil
            ),
            LocalizableKey(
                key: "isolation_indicator_accessiblity_label days: %ld date: %@ time: %@",
                keyWithSuffix: nil
            ),
        ]

        XCTAssertEqual(expectedSet, parser.keys)
    }

}
