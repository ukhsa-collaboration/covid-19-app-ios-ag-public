//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Scenarios
import TestSupport
import XCTest
@testable import Domain

class LocalAuthoritiesManagerTests: XCTestCase {
    private var localAuthoritiesValidator: MockLocalAuthoritiesValidator!
    private var postcodeStore: PostcodeStore!
    private var manager: LocalAuthorityManager!

    override func setUp() {
        localAuthoritiesValidator = MockLocalAuthoritiesValidator()
        postcodeStore = PostcodeStore(store: MockEncryptedStore())
        manager = LocalAuthorityManager(localAuthoritiesValidator: localAuthoritiesValidator, postcodeStore: postcodeStore)
    }

    func testHasLocalAuthority() {
        let postcode = Postcode("B44")
        let localAuthority = LocalAuthorityId("LA1")
        postcodeStore.save(postcode: postcode, localAuthorityId: localAuthority)
        XCTAssertEqual(manager.country, .england)
    }

    func testHasLocalAuthorityInWales() {
        let postcode = Postcode("AB11")
        let localAuthority = LocalAuthorityId("WLA2")
        postcodeStore.save(postcode: postcode, localAuthorityId: localAuthority)
        XCTAssertEqual(manager.country, .wales)
    }

    func testHasLocalAuthorityInScotland() {
        let postcode = Postcode("AB15")
        let localAuthority = LocalAuthorityId("SLA2")
        postcodeStore.save(postcode: postcode, localAuthorityId: localAuthority)
        XCTAssertEqual(manager.country, .england)
    }

    func testStoreValidCountryLocalAuthority() {
        let postcode = Postcode("B44")
        let localAuthority = LocalAuthority(name: "Local Authority", id: .init("LA1"), country: .england)

        let result = manager.store(postcode: postcode, localAuthority: localAuthority)
        if case .success = result {} else {
            XCTFail()
        }
        XCTAssertEqual(postcodeStore.postcode.currentValue, postcode)
        XCTAssertEqual(postcodeStore.localAuthorityId.currentValue, localAuthority.id)
    }

    func testStoreInvalidCountryLocalAuthority() {
        let postcode = Postcode("B44")
        let localAuthority = LocalAuthority(name: "Local Authority", id: .init("LA1"), country: nil)

        let result = manager.store(postcode: postcode, localAuthority: localAuthority)
        if case .failure = result {} else {
            XCTFail()
        }
    }

    func testGetLocalAuthoritiesForPostcode() {
        let postcode = Postcode("B44")
        let localAuthority = LocalAuthority(name: "Local Authority", id: .init("LA1"), country: nil)
        localAuthoritiesValidator.resultSet = [localAuthority]

        let result = manager.localAuthorities(for: postcode)
        TS.assert(
            result,
            equals: Result<Set<LocalAuthority>, PostcodeValidationError>.success([localAuthority])
        )
    }

}

private class MockLocalAuthoritiesValidator: LocalAuthoritiesValidating {
    var postcodeError: PostcodeValidationError?
    var resultSet: Set<LocalAuthority> = []

    func localAuthorities(for postcode: Postcode) -> Result<Set<LocalAuthority>, PostcodeValidationError> {
        if let error = postcodeError {
            return Result.failure(error)
        }

        return Result.success(resultSet)
    }

    func localAuthority(with localAuthorityId: LocalAuthorityId) -> LocalAuthority? {
        if localAuthorityId.value == "WLA2" {
            return LocalAuthority(
                name: "Wales Authority",
                id: LocalAuthorityId("WLA2"),
                country: .wales
            )
        } else if localAuthorityId.value == "SLA2" {
            return LocalAuthority(
                name: "Scotland Authority",
                id: LocalAuthorityId("SLA2"),
                country: nil
            )
        }
        return nil
    }
}
