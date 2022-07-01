//
// Copyright © 2020 NHSX. All rights reserved.
//

import XCTest
@testable import Interface

class PostcodeProcessorTests: XCTestCase {

    func testValidPostcode() {
        let postcode = "BO13"

        XCTAssertEqual(PostcodeProcessor.process(postcode), "BO13")
    }

    func testValidPostcodeLowercase() {
        let postcode = "wb23"

        XCTAssertEqual(PostcodeProcessor.process(postcode), "WB23")
    }

    func testPrefixingPostcode() {
        let postcode = "7AB38O"

        XCTAssertEqual(PostcodeProcessor.process(postcode), "7AB3")
    }

    func testPartialPostcodeEntry() {
        let postcode = "A1"

        XCTAssertEqual(PostcodeProcessor.process(postcode), "A1")
    }

    func testSingleCharacterInput() {
        let postcode = "3"

        XCTAssertEqual(PostcodeProcessor.process(postcode), "3")
    }

    func testExtractPartialPostcode() {
        let postcode = "C3 ABC"

        XCTAssertEqual(PostcodeProcessor.process(postcode), "C3")
    }

    func testEmptyPostcode() {
        let postcode = ""

        XCTAssertEqual(PostcodeProcessor.process(postcode), "")
    }

    func testLeadingSpaces() {
        let postcode = "  B5 C34"

        XCTAssertEqual(PostcodeProcessor.process(postcode), "B5")
    }

    func testTrailingSpaces() {
        let postcode = "Z8    "
        XCTAssertEqual(PostcodeProcessor.process(postcode), "Z8")
    }

    func testSurroundingSpaces() {
        let postcode = "   C1  "

        XCTAssertEqual(PostcodeProcessor.process(postcode), "C1")
    }

    func testEmptyString() {
        let postcode = ""

        XCTAssertEqual(PostcodeProcessor.process(postcode), "")
    }

    func testIgnoreNonAlphanumbericCharacter() {
        let postcode = " \nL4; ! 3"

        XCTAssertEqual(PostcodeProcessor.process(postcode), "L4")
    }

}
