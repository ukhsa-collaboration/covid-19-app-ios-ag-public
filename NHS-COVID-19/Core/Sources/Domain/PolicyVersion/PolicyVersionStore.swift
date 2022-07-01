//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation

private struct PolicyVersionInfo: Codable, DataConvertible {
    var lastAcceptedWithAppVersion: String

    init(_ version: String) {
        lastAcceptedWithAppVersion = version
    }
}

public class PolicyVersionStore {

    @PublishedEncrypted private var policyInfo: PolicyVersionInfo?

    private(set) lazy var lastAcceptedWithAppVersion: DomainProperty<String?> = {
        $policyInfo.map { $0?.lastAcceptedWithAppVersion }
    }()

    init(store: EncryptedStoring) {
        _policyInfo = store.encrypted("policy_version")
    }

    func save(currentAppVersion: String) {
        policyInfo = PolicyVersionInfo(currentAppVersion)
    }
}
