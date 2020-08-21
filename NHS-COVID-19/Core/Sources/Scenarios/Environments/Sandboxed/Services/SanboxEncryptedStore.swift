//
// Copyright © 2020 NHSX. All rights reserved.
//

import Domain
import Foundation

class SandboxEncryptedStore: EncryptedStoring {
    
    fileprivate var stored = [String: Data]()
    private let host: SandboxHost
    
    init(host: SandboxHost) {
        self.host = host
        if host.initialState.isPilotActivated {
            stored["activation"] = """
            { "isActivated": true }
            """.data(using: .utf8)
        }
        
        if let postcode = host.initialState.postcode {
            if let riskLevel = host.initialState.riskLevel {
                stored["postcode"] = """
                {
                    "postcode": "\(postcode)",
                    "riskLevel": "\(riskLevel)"
                }
                """.data(using: .utf8)!
            } else {
                stored["postcode"] = """
                { "postcode": "\(postcode)" }
                """.data(using: .utf8)!
            }
            
        }
    }
    
    func dataEncryptor(_ name: String) -> DataEncrypting {
        SandboxEncryptor(store: self, name: name)
    }
    
}

private struct SandboxEncryptor: DataEncrypting {
    
    var store: SandboxEncryptedStore
    var name: String
    
    var wrappedValue: Data? {
        get {
            store.stored[name]
        }
        nonmutating set {
            store.stored[name] = newValue
        }
    }
    
    var hasValue: Bool {
        wrappedValue != nil
    }
    
}
