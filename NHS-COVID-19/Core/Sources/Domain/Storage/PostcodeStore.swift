//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

private struct PostcodeInfo: Codable, DataConvertible {
    var postcode: Postcode
    
    init(_ postcode: Postcode) {
        self.postcode = postcode
    }
}

public class PostcodeStore {
    
    @Encrypted private var postcodeInfo: PostcodeInfo? {
        didSet {
            hasPostcode = $postcodeInfo.hasValue
            postcode = postcodeInfo?.postcode
        }
    }
    
    @Published
    private(set) var hasPostcode: Bool
    
    @Published
    private(set) var postcode: Postcode?
    
    init(store: EncryptedStoring) {
        _postcodeInfo = store.encrypted("postcode")
        let info = _postcodeInfo.wrappedValue
        hasPostcode = info != nil
        postcode = info?.postcode
    }
    
    func save(postcode: Postcode) {
        postcodeInfo = PostcodeInfo(postcode)
    }
    
    func delete() {
        postcodeInfo = nil
    }
}
