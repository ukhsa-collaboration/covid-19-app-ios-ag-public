//
// Copyright © 2020 NHSX. All rights reserved.
//

import CoreServices
import TestSupport
import UIKit
import XCTest

class ImageComparisonTests: XCTestCase {
    func testImageComparisonEqual() throws {
        let bundle = Bundle(for: Self.self)

        let imageA = try XCTUnwrap(UIImage(named: "Generated/ImageA", in: bundle, with: nil).createCIImage())
        let imageB = try XCTUnwrap(UIImage(named: "Generated/ImageA", in: bundle, with: nil).createCIImage())

        let comparison = try CIImage.compare(imageA, with: imageB)

        guard case .equal = comparison else {
            XCTFail()
            return
        }
    }

    func testImageComparisonNotEqual() throws {
        let bundle = Bundle(for: Self.self)

        let imageA = try XCTUnwrap(UIImage(named: "Generated/ImageA", in: bundle, with: nil).createCIImage())
        let imageB = try XCTUnwrap(UIImage(named: "Generated/ImageB", in: bundle, with: nil).createCIImage())

        let comparison = try CIImage.compare(imageA, with: imageB)

        guard case .notEqual = comparison else {
            XCTFail()
            return
        }
    }

    func testImageDiffIsAsExpected() throws {
        let bundle = Bundle(for: Self.self)

        let imageA = try XCTUnwrap(UIImage(named: "Generated/ImageA", in: bundle, with: nil).createCIImage())
        let imageB = try XCTUnwrap(UIImage(named: "Generated/ImageB", in: bundle, with: nil).createCIImage())
        let expectedDiff = try XCTUnwrap(UIImage(named: "Generated/Diff", in: bundle, with: nil).createCIImage())

        let diff = try XCTUnwrap(CIImage.diff(imageA, with: imageB))

        // Save to file and recall, as this ensures the `diff` goes through the same processing as the `expectedDiff` did

        let resourceURL = try XCTUnwrap(bundle.resourceURL)
        let diffURL = resourceURL.appendingPathComponent("TempDiff.png")
        let diffPNGData = try XCTUnwrap(UIImage(ciImage: diff).pngData())
        try diffPNGData.write(to: diffURL)
        let reloadedDiff = CIImage(contentsOf: diffURL)

        let comparison = try CIImage.compare(expectedDiff, with: reloadedDiff)

        guard case .equal = comparison else {
            XCTFail()
            return
        }
    }
}
