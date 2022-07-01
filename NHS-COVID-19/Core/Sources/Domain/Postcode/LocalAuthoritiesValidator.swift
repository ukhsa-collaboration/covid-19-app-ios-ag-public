//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation

protocol LocalAuthoritiesValidating {
    func localAuthorities(for postcode: Postcode) -> Result<Set<LocalAuthority>, PostcodeValidationError>
    func localAuthority(with localAuthorityId: LocalAuthorityId) -> LocalAuthority?
}

public struct LocalAuthority: Equatable, Hashable {
    public var name: String
    public var id: LocalAuthorityId
    var country: Country?
}

struct LocalAuthoritiesValidator: LocalAuthoritiesValidating {
    struct LocalAuthorityPayload: Codable {
        fileprivate let name: String
        fileprivate let country: String

        fileprivate init(name: String, country: String) {
            self.name = name
            self.country = country
        }
    }

    struct LocalAuthoritiesPayload: Codable {
        fileprivate let postcodes: [String: Set<String>]
        fileprivate let localAuthorities: [String: LocalAuthorityPayload]

        fileprivate init(
            postcodes: [String: Set<String>],
            localAuthorities: [String: LocalAuthorityPayload]
        ) {
            self.postcodes = postcodes
            self.localAuthorities = localAuthorities
        }
    }

    private let payload: LocalAuthoritiesPayload
    private let postcodes: [Postcode: Set<LocalAuthorityId>]
    private let localAuthorities: [LocalAuthorityId: LocalAuthority]

    init(data: Data) throws {
        payload = try JSONDecoder().decode(LocalAuthoritiesPayload.self, from: data)
        postcodes = Dictionary(uniqueKeysWithValues: payload.postcodes.map { key, value in
            (Postcode(key), Set(value.map { LocalAuthorityId($0) }))
        })
        localAuthorities = Dictionary(uniqueKeysWithValues: payload.localAuthorities.map { key, value in
            let localAuthorityId = LocalAuthorityId(key)
            let localAuthority = LocalAuthority(
                name: value.name,
                id: localAuthorityId,
                country: {
                    switch value.country {
                    case "England": return .england
                    case "Wales": return .wales
                    default: return nil
                    }
                }()
            )
            return (localAuthorityId, localAuthority)
        })
    }

    init() {
        guard
            let url = Bundle.module.url(forResource: "LocalAuthorities", withExtension: "json"),
            let data = try? Data(contentsOf: url),
            let validator = try? LocalAuthoritiesValidator(data: data)
        else {
            Thread.preconditionFailure("Unable to parse resource for valid local authorities (LocalAuthorities.json)")
        }
        self = validator
    }

    func localAuthorities(for postcode: Postcode) -> Result<Set<LocalAuthority>, PostcodeValidationError> {
        guard let localIds = postcodes[postcode], localIds.count > 0 else {
            return .failure(.invalidPostcode)
        }
        let localAuthorities = localIds.map { self.localAuthority(with: $0) }.compactMap { $0 }
        guard localAuthorities.count > 0 else {
            return .failure(.invalidPostcode)
        }
        guard localAuthorities.contains(where: { $0.country != nil }) else {
            return .failure(.unsupportedCountry)
        }
        return .success(Set(localAuthorities))
    }

    func localAuthority(with localAuthorityId: LocalAuthorityId) -> LocalAuthority? {
        return localAuthorities[localAuthorityId]
    }
}
