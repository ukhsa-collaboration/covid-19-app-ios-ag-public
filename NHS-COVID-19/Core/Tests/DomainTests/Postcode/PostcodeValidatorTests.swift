//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import XCTest
@testable import Domain

class PostcodeValidatorTests: XCTestCase {
    var postcodeValidator: PostcodeValidator!
    
    override func setUpWithError() throws {
        let data = """
        {
            "England": ["E1", "E2"],
            "Wales": ["W1", "W2"],
            "Scotland": ["S1"],
            "NorthenIreland": ["N1"],
        }
        """.data(using: .utf8)!
        postcodeValidator = try PostcodeValidator(data: data)
    }
    
    func testCreatingValidatorWithInvalidDataFails() {
        XCTAssertThrowsError(try PostcodeValidator(data: Data()))
    }
    
    func testValidPostcodesFromEngland() {
        XCTAssertEqual(postcodeValidator.country(for: Postcode("E1")), .england)
        XCTAssertEqual(postcodeValidator.country(for: Postcode("E2")), .england)
        XCTAssertTrue(postcodeValidator.isValid(Postcode("E1")))
        XCTAssertTrue(postcodeValidator.isValid(Postcode("E2")))
    }
    
    func testValidPostcodesFromWales() {
        XCTAssertEqual(postcodeValidator.country(for: Postcode("W1")), .wales)
        XCTAssertEqual(postcodeValidator.country(for: Postcode("W2")), .wales)
        XCTAssertTrue(postcodeValidator.isValid(Postcode("W1")))
        XCTAssertTrue(postcodeValidator.isValid(Postcode("W2")))
    }
    
    func testValidPostcodesFromScotland() {
        XCTAssertNil(postcodeValidator.country(for: Postcode("S1")))
        XCTAssertTrue(postcodeValidator.isValid(Postcode("S1")))
    }
    
    func testValidPostcodesFromNorthenIreland() {
        XCTAssertNil(postcodeValidator.country(for: Postcode("N1")))
        XCTAssertTrue(postcodeValidator.isValid(Postcode("N1")))
    }
    
    func testInvalidPostcode() {
        XCTAssertFalse(postcodeValidator.isValid(Postcode("AB11")))
    }
}
