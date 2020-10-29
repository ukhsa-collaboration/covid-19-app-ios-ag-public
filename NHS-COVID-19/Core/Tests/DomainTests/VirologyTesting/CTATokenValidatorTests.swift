//
// Copyright © 2020 NHSX. All rights reserved.
//

import XCTest
@testable import Domain

class CTATokenValidatorTests: XCTestCase {
    private var validator: CTATokenValidator!
    
    override func setUp() {
        validator = CTATokenValidator()
    }
    
    func testValidateCorrectCode() {
        XCTAssertTrue(validator.validate("f3dzcfdt"))
        XCTAssertTrue(validator.validate("8vb7xehg"))
    }
    
    func testValidateEmptyCode() {
        XCTAssertFalse(validator.validate(""))
    }
    
    func testValidateInvalidCharacters() {
        XCTAssertFalse(validator.validate("∞"))
        XCTAssertFalse(validator.validate("8ub7xehg"))
    }
    
    func testValidateIncorrectCode() {
        XCTAssertFalse(validator.validate("f3dzcfdx"))
        XCTAssertFalse(validator.validate("8vb7xehb"))
    }
}
