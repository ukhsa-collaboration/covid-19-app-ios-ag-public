//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation

private struct PostcodeInfo: Codable, DataConvertible {
    var postcode: Postcode
    var localAuthorityId: LocalAuthorityId?
    
    // This Makes it similar to what we do for postcode.
    init(_ postcode: Postcode, localAuthorityId: LocalAuthorityId?) {
        self.postcode = postcode
        self.localAuthorityId = localAuthorityId
    }
}

enum PostcodeStoreState {
    case empty
    case onlyPostcode
    case postcodeAndLocalAuthority
    
    init(hasPostcode: Bool, hasLocalAuthority: Bool) {
        if hasPostcode, hasLocalAuthority {
            self = .postcodeAndLocalAuthority
        } else if hasPostcode {
            self = .onlyPostcode
        } else {
            self = .empty
        }
    }
}

public class PostcodeStore {
    
    @PublishedEncrypted private var postcodeInfo: PostcodeInfo?
    
    private(set) lazy var state: DomainProperty<PostcodeStoreState> = {
        $postcodeInfo.map { PostcodeStoreState(hasPostcode: $0?.postcode != nil, hasLocalAuthority: $0?.localAuthorityId != nil) }
    }()
    
    private(set) lazy var postcode: DomainProperty<Postcode?> = {
        $postcodeInfo.map { $0?.postcode }
    }()
    
    private(set) lazy var localAuthorityId: DomainProperty<LocalAuthorityId?> = {
        $postcodeInfo.map { $0?.localAuthorityId }
    }()
    
    init(store: EncryptedStoring) {
        _postcodeInfo = store.encrypted("postcode")
    }
    
    func save(postcode: Postcode) {
        postcodeInfo = PostcodeInfo(postcode, localAuthorityId: nil)
    }
    
    func save(postcode: Postcode, localAuthorityId: LocalAuthorityId) {
        postcodeInfo = PostcodeInfo(postcode, localAuthorityId: localAuthorityId)
    }
    
    func delete() {
        postcodeInfo = nil
    }
}
