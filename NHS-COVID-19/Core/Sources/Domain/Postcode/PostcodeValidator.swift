//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

public protocol PostcodeValidating {
    func isValid(_ postcode: Postcode) -> Bool
    func country(for postcode: Postcode) -> Country?
}

public enum PostcodeValidationError: Error {
    case invalidPostcode
    case unsupportedCountry
}

extension PostcodeValidating {

    func validatedPostcode(from value: String) -> Result<Postcode, PostcodeValidationError> {
        let postcode = Postcode(value)
        guard isValid(postcode) else {
            return .failure(.invalidPostcode)
        }
        guard country(for: postcode) != nil else {
            return .failure(.unsupportedCountry)
        }
        return .success(postcode)
    }

}

public struct PostcodeValidator: PostcodeValidating {
    private var countryForPostcode = [Postcode: Country]()
    private var otherKnownPostcodes = Set<Postcode>()

    private init(validPostcodesByAuthority: [String: Set<Postcode>]) {
        validPostcodesByAuthority.forEach { countryName, postcodes in
            var country: Country
            switch countryName {
            case "England":
                country = .england
            case "Wales":
                country = .wales
            default:
                otherKnownPostcodes.formUnion(postcodes)
                return
            }

            postcodes.forEach { postcode in
                countryForPostcode[postcode] = country
            }
        }
    }

    public func country(for postcode: Postcode) -> Country? {
        countryForPostcode[postcode]
    }

    public func isValid(_ postcode: Postcode) -> Bool {
        country(for: postcode) != nil || otherKnownPostcodes.contains(postcode)
    }
}

extension PostcodeValidator {

    init(data: Data) throws {
        self.init(
            validPostcodesByAuthority: try JSONDecoder().decode([String: Set<Postcode>].self, from: data)
        )
    }

    public init() {
        guard
            let url = Bundle.main.url(forResource: "PostalDistricts", withExtension: ".json"),
            let data = try? Data(contentsOf: url),
            let validator = try? PostcodeValidator(data: data)
        else {
            preconditionFailure("Unable to parse resource for valid postcodes (PostalDistricts.json)")
        }
        self = validator
    }
}
