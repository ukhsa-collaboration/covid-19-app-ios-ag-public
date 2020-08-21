//
// Copyright © 2020 NHSX. All rights reserved.
//

import Domain

public struct MockPostcodeValidator: PostcodeValidating {
    public var validPostcodes = Set<String>()
    
    public func isValid(_ postcode: String) -> Bool {
        validPostcodes.contains(postcode)
    }
    
    public init() {}
}
