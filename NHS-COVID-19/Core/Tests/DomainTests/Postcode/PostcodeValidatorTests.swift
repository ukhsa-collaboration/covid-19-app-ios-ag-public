//
// Copyright © 2020 NHSX. All rights reserved.
//

import XCTest
@testable import Domain

class PostcodeValidatorTests: XCTestCase {
    var postcodeValidator: PostcodeValidator!
    
    override func setUp() {
        postcodeValidator = PostcodeValidator(validPostcodes: ["AB10"])
    }
    
    func testValidPostcode() {
        XCTAssertTrue(postcodeValidator.isValid("AB10"))
    }
    
    func testInvalidPostcode() {
        XCTAssertFalse(postcodeValidator.isValid("AB11"))
    }
    
    func testLowercasePostcodeIsValid() {
        XCTAssertTrue(postcodeValidator.isValid("ab10"))
    }
}
