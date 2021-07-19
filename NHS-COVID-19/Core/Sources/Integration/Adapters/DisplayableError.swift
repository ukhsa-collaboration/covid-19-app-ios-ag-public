//
// Copyright © 2021 DHSC. All rights reserved.
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
}
