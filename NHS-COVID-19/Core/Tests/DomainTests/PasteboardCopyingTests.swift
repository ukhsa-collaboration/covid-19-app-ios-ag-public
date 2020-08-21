//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Domain
import Scenarios
import XCTest

class PasteboardCopierTests: XCTestCase {
    
    func testPasteboardCopier() {
        let referenceCode = String.random()
        let pasteboardCopier = PasteboardCopier()
        pasteboardCopier.copyToPasteboard(value: referenceCode)
        XCTAssertEqual(UIPasteboard.general.string, referenceCode)
    }
}
