//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import XCTest
@testable import Common

class FilterNilTests: XCTestCase {
    func testFilterNil() {
        var receivedValues = [Int]()

        let cancellable = Publishers.Sequence<[Int?], Never>(sequence: [0, nil, 1, nil, nil, 2])
            .filterNil()
            .sink { value in
                receivedValues.append(value)
            }

        XCTAssertEqual(receivedValues, [0, 1, 2])
        cancellable.cancel()
    }
}
