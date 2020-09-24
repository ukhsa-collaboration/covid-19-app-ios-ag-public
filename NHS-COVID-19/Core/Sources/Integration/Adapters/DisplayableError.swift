//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Domain
import Foundation
import Interface
import Localization

extension DisplayableError {
    
    init(_ postcodeValidationError: PostcodeValidationError) {
        switch postcodeValidationError {
        case .invalidPostcode:
            self.init(.postcode_entry_error_description)
        case .unsupportedCountry:
            self.init(.postcode_entry_error_description_unsupported_country)
        }
    }
    
    init(_ linkTestResultError: LinkTestResultError) {
        switch linkTestResultError {
        case .invalidCode:
            self.init(.link_test_result_enter_code_invalid_error)
        case .noInternet:
            self.init(.network_error_no_internet_connection)
        case .unknownError:
            self.init(.network_error_general)
        }
    }
    
}
