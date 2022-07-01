//
// Copyright © 2020 NHSX. All rights reserved.
//

import UIKit
import XCTest
@testable import Interface

class ColorTests: XCTestCase {

    func testAllColorsHaveValue() {
        ColorName.allCases.forEach {
            XCTAssert(UIColor.hasColor(for: $0), "No color defined for “\($0.rawValue)”")
        }
    }

}
