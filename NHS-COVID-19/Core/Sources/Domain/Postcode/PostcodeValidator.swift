//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

public protocol PostcodeValidating {
    func isValid(_ postcode: String) -> Bool
}

public struct PostcodeValidator: PostcodeValidating {
    private let validPostcodes: Set<String>
    
    init(validPostcodes: Set<String>) {
        self.validPostcodes = validPostcodes
    }
    
    public func isValid(_ postcode: String) -> Bool {
        validPostcodes.contains(postcode.uppercased())
    }
}

extension PostcodeValidator {
    public init() {
        guard
            let url = Bundle.main.url(forResource: "PostalDistricts", withExtension: ".json"),
            let data = try? Data(contentsOf: url),
            let set = try? JSONDecoder().decode(Set<String>.self, from: data)
        else {
            preconditionFailure("Unable to parse resource for valid postcodes (PostalDistricts.json)")
        }
        self.init(validPostcodes: set)
    }
}
