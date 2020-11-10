//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

private struct PolicyVersionInfo: Codable, DataConvertible {
    var lastAcceptedWithAppVersion: String
    
    init(_ version: String) {
        lastAcceptedWithAppVersion = version
    }
}

public class PolicyVersionStore {
    
    @Encrypted private var policyInfo: PolicyVersionInfo? {
        didSet {
            lastAcceptedWithAppVersion = policyInfo?.lastAcceptedWithAppVersion
        }
    }
    
    @Published
    private(set) var lastAcceptedWithAppVersion: String?
    
    init(store: EncryptedStoring) {
        _policyInfo = store.encrypted("policy_version")
        let info = _policyInfo.wrappedValue
        lastAcceptedWithAppVersion = info?.lastAcceptedWithAppVersion
    }
    
    func save(currentAppVersion: String) {
        policyInfo = PolicyVersionInfo(currentAppVersion)
    }
}
