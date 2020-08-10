//
// Copyright © 2020 NHSX. All rights reserved.
//

import CryptoKit
import Foundation

extension SymmetricKey: DataConvertible {
    var data: Data {
        withUnsafeBytes { Data($0) }
    }
}

extension AES.GCM.Nonce: DataConvertible {
    var data: Data {
        Data(self)
    }
}

extension String: DataConvertible {
    init(data: Data) {
        self = String(data: data, encoding: .utf8)!
    }
    
    var data: Data {
        self.data(using: .utf8)!
    }
}

public protocol DataEncrypting {
    var wrappedValue: Data? { get nonmutating set }
    var hasValue: Bool { get }
}

struct DataEncryptor: DataEncrypting {
    @KeychainStored private var key: SymmetricKey?
    @KeychainStored private var tag: Data?
    @FileStored private var ciphertext: Data?
    
    init(keychain: Keychain, storage: FileStorage, name: String) {
        _key = KeychainStored(keychain: keychain, key: "\(name).key")
        _tag = KeychainStored(keychain: keychain, key: "\(name).tag")
        _ciphertext = FileStored(storage: storage, name: name)
        
        if !$ciphertext.hasValue {
            delete()
        }
    }
    
    var projectedValue: Self {
        self
    }
    
    var wrappedValue: Data? {
        get {
            get()
        }
        
        nonmutating set {
            if let value = newValue {
                set(value)
            } else {
                delete()
            }
        }
        
    }
    
    var hasValue: Bool {
        $key.hasValue && $tag.hasValue && $ciphertext.hasValue
    }
    
    private func get() -> Data? {
        guard let ciphertext = ciphertext,
            let key = key,
            let tag = tag,
            let sealedBox = try? AES.GCM.SealedBox(combined: ciphertext),
            let plaintext = try? AES.GCM.open(sealedBox, using: key, authenticating: tag) else {
            delete()
            return nil
        }
        return plaintext
    }
    
    private func set(_ value: Data) {
        let key = $key.get { SymmetricKey(size: .bits256) }
        let nonce = AES.GCM.Nonce()
        let tag = $tag.get { UUID().uuidString.data(using: .utf8)! }
        
        let sealedBox = try? AES.GCM.seal(value, using: key, nonce: nonce, authenticating: tag)
        ciphertext = sealedBox?.combined
    }
    
    private func delete() {
        key = nil
        tag = nil
        ciphertext = nil
    }
}
