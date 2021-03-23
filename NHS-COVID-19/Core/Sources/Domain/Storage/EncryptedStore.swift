//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation

public protocol EncryptedStoring {
    
    func dataEncryptor(_ name: String) -> DataEncrypting
    
}

extension EncryptedStoring {
    
    func encrypted<Wrapped>(_ name: String) -> Encrypted<Wrapped> {
        Encrypted(dataEncryptor(name))
    }
    
    func encrypted<Wrapped>(_ name: String) -> PublishedEncrypted<Wrapped> {
        PublishedEncrypted(dataEncryptor(name))
    }
    
}

public class EncryptedStore: EncryptedStoring {
    
    private let keychain: Keychain
    private let storage: FileStorage
    
    init(keychain: Keychain, storage: FileStorage) {
        self.keychain = keychain
        self.storage = storage
    }
    
    public convenience init(service: String) {
        self.init(
            keychain: Keychain(service: service),
            storage: FileStorage(forDocumentsOf: service)
        )
    }
    
    public func dataEncryptor(_ name: String) -> DataEncrypting {
        DataEncryptor(keychain: keychain, storage: storage, name: name)
    }
    
}
