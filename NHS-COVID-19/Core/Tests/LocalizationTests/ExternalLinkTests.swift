//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation
import XCTest
@testable import Localization

class ExternalLinkTests: XCTestCase {

    override func tearDown() {
        Localization.country = Country.england
    }

    func testExternalLinksEngland() {

        Localization.country = Country.england

        ExternalLink.allCases.forEach { link in
            let url = link.url
            XCTAssertEqual(url.scheme, "https")
        }
    }

    func testExternalLinksWales() {

        Localization.country = Country.wales

        ExternalLink.allCases.forEach { link in
            let url = link.url
            XCTAssertEqual(url.scheme, "https")
        }
    }
}
