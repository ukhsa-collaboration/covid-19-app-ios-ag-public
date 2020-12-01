//
// Copyright © 2020 NHSX. All rights reserved.
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
    
    @Encrypted private var postcodeInfo: PostcodeInfo? {
        didSet {
            state = PostcodeStoreState(hasPostcode: postcodeInfo?.postcode != nil, hasLocalAuthority: postcodeInfo?.localAuthorityId != nil)
            postcode = postcodeInfo?.postcode
            localAuthorityId = postcodeInfo?.localAuthorityId
        }
    }
    
    @Published
    private(set) var state: PostcodeStoreState
    
    @Published
    private(set) var postcode: Postcode?
    
    @Published
    private(set) var localAuthorityId: LocalAuthorityId?
    
    init(store: EncryptedStoring) {
        _postcodeInfo = store.encrypted("postcode")
        let info = _postcodeInfo.wrappedValue
        postcode = info?.postcode
        localAuthorityId = info?.localAuthorityId
        state = PostcodeStoreState(hasPostcode: info?.postcode != nil, hasLocalAuthority: info?.localAuthorityId != nil)
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
