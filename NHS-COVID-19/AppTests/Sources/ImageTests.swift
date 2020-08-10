//
// Copyright © 2020 NHSX. All rights reserved.
//

import UIKit
import XCTest
@testable import Interface

class ImageTests: XCTestCase {
    
    func testAllImagesHaveValue() {
        ImageName.allCases.forEach {
            XCTAssert(UIImage.hasImage(for: $0), "No image defined for “\($0.rawValue)”")
        }
    }
    
}
