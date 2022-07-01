//
// Copyright © 2021 DHSC. All rights reserved.
//

import XCTest

final class XCUIFullScreenshotTests: XCTestCase {

    // Maybe add test for calculator init? e.g. it could throw an error if wrong value is passed

    func testTwoOffsets() {
        let offsetCalculator = ScreenshotOffsetCalculator(
            scrollableViewHeight: 734,
            scrollableContentViewHeight: 892.3,
            topPadding: 44,
            bottomPadding: 34
        )

        let expectedOffsets = [
            ScreenshotPaddings(top: 0, bottom: 34),
            ScreenshotPaddings(top: 620, bottom: 0),
        ]

        var offsets = [ScreenshotPaddings]()
        offsets.append(offsetCalculator.calculateScreenshotPaddings(currentOffset: 44))
        offsets.append(offsetCalculator.calculateScreenshotPaddings(currentOffset: -114))

        XCTAssertEqual(expectedOffsets, offsets)
    }

    func testOffsetsTwo1() {
        let offsetCalculator = ScreenshotOffsetCalculator(
            scrollableViewHeight: 734,
            scrollableContentViewHeight: 1255.7,
            topPadding: 44,
            bottomPadding: 34
        )

        let expectedOffsets = [
            ScreenshotPaddings(top: 0, bottom: 34),
            ScreenshotPaddings(top: 257, bottom: 0),
        ]

        var offsets = [ScreenshotPaddings]()
        offsets.append(offsetCalculator.calculateScreenshotPaddings(currentOffset: 44))
        offsets.append(offsetCalculator.calculateScreenshotPaddings(currentOffset: -477))

        XCTAssertEqual(expectedOffsets, offsets)
    }

    func testOffsetsThree() {
        let offsetCalculator = ScreenshotOffsetCalculator(
            scrollableViewHeight: 734,
            scrollableContentViewHeight: 1619,
            topPadding: 44,
            bottomPadding: 34
        )

        let expectedOffsets = [
            ScreenshotPaddings(top: 0, bottom: 34),
            ScreenshotPaddings(top: 116, bottom: 34),
            ScreenshotPaddings(top: 555, bottom: 0),
        ]

        var offsets = [ScreenshotPaddings]()
        offsets.append(offsetCalculator.calculateScreenshotPaddings(currentOffset: 44))
        offsets.append(offsetCalculator.calculateScreenshotPaddings(currentOffset: -618))
        offsets.append(offsetCalculator.calculateScreenshotPaddings(currentOffset: -841))

        XCTAssertEqual(expectedOffsets, offsets)
    }

    func testOffsetsFour() {
        let offsetCalculator = ScreenshotOffsetCalculator(
            scrollableViewHeight: 734,
            scrollableContentViewHeight: 2345.7,
            topPadding: 44,
            bottomPadding: 34
        )

        let expectedOffsets = [
            ScreenshotPaddings(top: 0, bottom: 34),
            ScreenshotPaddings(top: 109, bottom: 34),
            ScreenshotPaddings(top: 110, bottom: 34),
            ScreenshotPaddings(top: 503, bottom: 0),
        ]

        var offsets = [ScreenshotPaddings]()
        offsets.append(offsetCalculator.calculateScreenshotPaddings(currentOffset: 44))
        offsets.append(offsetCalculator.calculateScreenshotPaddings(currentOffset: -624.7))
        offsets.append(offsetCalculator.calculateScreenshotPaddings(currentOffset: -1293))
        offsets.append(offsetCalculator.calculateScreenshotPaddings(currentOffset: -1567.7))

        XCTAssertEqual(expectedOffsets, offsets)
    }

}
