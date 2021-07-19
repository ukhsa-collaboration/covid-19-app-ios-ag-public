//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Foundation

class PolicyVersionManager {
    private let policyVersionStore: PolicyVersionStore
    private var cancellable: AnyCancellable?
    private let currentVersion: Version
    private let neededVersion: String
    
    @Published
    private(set) var needsAcceptNewVersion: Bool
    
    init(encryptedStore: EncryptedStoring, currentVersion: Version, neededVersion: String) {
        policyVersionStore = PolicyVersionStore(store: encryptedStore)
        self.currentVersion = currentVersion
        self.neededVersion = neededVersion
        
        needsAcceptNewVersion = Self.acceptanceNeeded(
            acceptedVersion: policyVersionStore.lastAcceptedWithAppVersion.currentValue,
            neededVersion: neededVersion
        )
        
        cancellable = policyVersionStore.lastAcceptedWithAppVersion.sink { acceptedVersion in
            self.needsAcceptNewVersion = Self.acceptanceNeeded(
                acceptedVersion: acceptedVersion,
                neededVersion: neededVersion
            )
        }
    }
    
    private static func acceptanceNeeded(acceptedVersion: String?, neededVersion: String) -> Bool {
        guard let acceptedVersionString = acceptedVersion,
            let acceptedVersion = try? Version(acceptedVersionString)
        else {
            return true
        }
        
        guard let neededVersion = try? Version(neededVersion) else {
            return false
        }
        
        return acceptedVersion < neededVersion
    }
    
    func acceptWithCurrentAppVersion() {
        policyVersionStore.save(currentAppVersion: currentVersion.readableRepresentation)
    }
}
