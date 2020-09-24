//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Domain
import Interface
import Localization
import TestSupport
import XCTest
@testable import Integration

final class DisplayableErrorTests: XCTestCase {
    
    // MARK: - Postcode validation
    
    func testPostcodeInvalid() {
        let displayableError = DisplayableError(PostcodeValidationError.invalidPostcode)
        
        TS.assert(displayableError, equals: DisplayableError(.postcode_entry_error_description))
    }
    
    func testPostcodeCountryUnsupported() {
        let displayableError = DisplayableError(PostcodeValidationError.unsupportedCountry)
        
        TS.assert(displayableError, equals: DisplayableError(.postcode_entry_error_description_unsupported_country))
    }
    
}
