//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest
@testable import Domain

class PostcodeValidatingTests: XCTestCase {
    
    func testValidPostcodeCreation() throws {
        var validator = MockPostcodeValidator()
        let validPostcodeValue = "AB10"
        validator.validPostcodes = [Postcode(validPostcodeValue)]
        let postcode = validator.validatedPostcode(from: validPostcodeValue)
        XCTAssertEqual(postcode, .success(Postcode(validPostcodeValue)))
    }
    
    func testUnsupportedCountryPostcodeCreation() throws {
        var validator = MockPostcodeValidator()
        let validPostcodeValue = "AB10"
        validator.validPostcodes = [Postcode(validPostcodeValue)]
        validator.country = nil
        let postcode = validator.validatedPostcode(from: validPostcodeValue)
        XCTAssertEqual(postcode, .failure(.unsupportedCountry))
    }
    
    func testInvalidPostcodeCreation() {
        let validator = MockPostcodeValidator()
        let postcodeValue = "AB10"
        let postcode = validator.validatedPostcode(from: postcodeValue)
        XCTAssertEqual(postcode, .failure(.invalidPostcode))
    }
    
}
