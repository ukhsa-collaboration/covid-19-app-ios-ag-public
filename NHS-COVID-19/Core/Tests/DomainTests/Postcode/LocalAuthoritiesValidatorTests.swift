//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import TestSupport
import XCTest
@testable import Domain

class LocalAuthoritiesValidatorTests: XCTestCase {
    var laValidator: LocalAuthoritiesValidator!
    
    override func setUpWithError() throws {
        let data = """
        {
            "localAuthorities": {
                "E12000033": {
                    "name": "Aberdeen City",
                    "country": "England"
                },
                "S12000034": {
                    "name": "Aberdeenshire",
                    "country": "Scotland"
                },
                "N12003034": {
                    "name": "ni",
                    "country": "NorthernIreland"
                },
                "W12003034": {
                    "name": "wls",
                    "country": "Wales"
                }
            },
            "postcodes": {
                "AB11": ["E12000033"],
                "AB12": ["E12000033", "S12000034"],
                "AB13": [],
                "AB14": ["S12000034"],
                "AB15": ["N12003034"],
                "AB16": ["E12003031"]
            }
        }
        """.data(using: .utf8)!
        laValidator = try LocalAuthoritiesValidator(data: data)
    }
    
    func testLoadingLocalAuthorities() {
        let exit = Thread.detachSyncSupervised {
            _ = LocalAuthoritiesValidator()
        }
        XCTAssertEqual(exit, .normal)
    }
    
    func testIsValidForPostcodeWithNoLocalAuthorities() {
        TS.assert(
            laValidator.localAuthorities(for: Postcode("ab13")),
            equals: Result<Set<LocalAuthority>, PostcodeValidationError>.failure(.invalidPostcode)
        )
        TS.assert(
            laValidator.localAuthorities(for: Postcode("ab16")),
            equals: Result<Set<LocalAuthority>, PostcodeValidationError>.failure(.invalidPostcode)
        )
    }
    
    func testIsValidForPostcodeWithLocalAuthoritiyInEnglandOrWales() {
        TS.assert(
            laValidator.localAuthorities(for: Postcode("ab11")),
            equals: Result<Set<LocalAuthority>, PostcodeValidationError>
                .success([
                    LocalAuthority(name: "Aberdeen City", id: LocalAuthorityId("e12000033"), country: .england),
                ])
        )
        TS.assert(
            laValidator.localAuthorities(for: Postcode("ab12")),
            equals: Result<Set<LocalAuthority>, PostcodeValidationError>
                .success([
                    LocalAuthority(name: "Aberdeen City", id: LocalAuthorityId("e12000033"), country: .england),
                    LocalAuthority(name: "Aberdeenshire", id: LocalAuthorityId("s12000034"), country: nil),
                ])
        )
    }
    
    func testIsValidForPostcodeWithLocalAuthorityNotInEnglandOrWales() {
        TS.assert(
            laValidator.localAuthorities(for: Postcode("ab14")),
            equals: Result<Set<LocalAuthority>, PostcodeValidationError>.failure(.unsupportedCountry)
        )
        TS.assert(
            laValidator.localAuthorities(for: Postcode("ab15")),
            equals: Result<Set<LocalAuthority>, PostcodeValidationError>.failure(.unsupportedCountry)
        )
    }
}
