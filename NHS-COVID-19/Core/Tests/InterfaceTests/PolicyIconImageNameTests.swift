//
// Copyright © 2020 NHSX. All rights reserved.
//

import XCTest
@testable import Interface

class PolicyIconImageNameTests: XCTestCase {
    func testInvalidPolicIcon() {
        let icon = RiskLevelInfoViewController.Policy.iconFromName(string: "")
        XCTAssertEqual(icon, .riskLevelDefaultIcon)
    }

    func testValidPolicIcons() {
        let validIcons = [
            "meeting-people",
            "bars-and-pubs",
            "worship",
            "overnight-stays",
            "education",
            "travelling",
            "exercise",
            "weddings-and-funerals",
        ]
        validIcons.forEach {
            let icon = RiskLevelInfoViewController.Policy.iconFromName(string: $0)
            XCTAssertNotEqual(icon, .riskLevelDefaultIcon)
        }
    }
}
