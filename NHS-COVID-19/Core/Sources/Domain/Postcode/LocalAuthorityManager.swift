//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common

public struct LocalAuthorityUnsupportedCountryError: Error {}

class LocalAuthorityManager {
    
    @Published
    var country: Country = .england
    
    private let localAuthoritiesValidator: LocalAuthoritiesValidating
    private let postcodeStore: PostcodeStore
    private var cancellable: AnyCancellable?
    
    init(localAuthoritiesValidator: LocalAuthoritiesValidating, postcodeStore: PostcodeStore) {
        self.localAuthoritiesValidator = localAuthoritiesValidator
        self.postcodeStore = postcodeStore
        
        cancellable = postcodeStore.$localAuthorityId.sink { [weak self] localAuthorityId in
            guard let self = self else { return }
            if let localAuthorityId = localAuthorityId {
                self.country = localAuthoritiesValidator.localAuthority(with: localAuthorityId)?.country ?? .england
            } else {
                self.country = .england
            }
        }
    }
    
    func store(postcode: Postcode, localAuthority: LocalAuthority) -> Result<Void, LocalAuthorityUnsupportedCountryError> {
        guard localAuthority.country != nil else {
            return Result.failure(LocalAuthorityUnsupportedCountryError())
        }
        postcodeStore.save(postcode: postcode, localAuthorityId: localAuthority.id)
        return Result.success(())
    }
    
    func localAuthorities(for postcode: Postcode) -> Result<Set<LocalAuthority>, PostcodeValidationError> {
        return localAuthoritiesValidator.localAuthorities(for: postcode)
    }
}
