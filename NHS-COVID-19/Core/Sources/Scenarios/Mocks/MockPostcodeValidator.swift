//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Domain

public struct MockPostcodeValidator: PostcodeValidating {
    public var validPostcodes = Set<Postcode>()
    public var country: Country? = Country.england
    
    public init() {}
    
    public func isValid(_ postcode: Postcode) -> Bool {
        validPostcodes.contains(postcode)
    }
    
    public func country(for postcode: Postcode) -> Country? {
        country
    }
}
