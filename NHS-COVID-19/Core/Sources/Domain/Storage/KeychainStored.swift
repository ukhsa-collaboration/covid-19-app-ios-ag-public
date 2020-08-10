//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

protocol DataConvertible {
    var data: Data { get }
    init(data: Data) throws
}

extension DataConvertible where Self: Codable {
    var data: Data {
        try! JSONEncoder().encode(self)
    }
    
    init(data: Data) throws {
        self = try JSONDecoder().decode(Self.self, from: data)
    }
}

extension Data: DataConvertible {
    var data: Data {
        self
    }
    
    init(data: Data) throws {
        self = data
    }
}

extension Date: DataConvertible {}

extension KeychainStored {
    func get(create: () -> Wrapped) -> Wrapped {
        if let wrappedValue = wrappedValue {
            return wrappedValue
        } else {
            let wrappedValue = create()
            self.wrappedValue = wrappedValue
            return wrappedValue
        }
    }
}

@propertyWrapper
struct KeychainStored<Wrapped: DataConvertible> {
    private var keychain: Keychain
    private var key: String
    
    init(keychain: Keychain, key: String) {
        self.keychain = keychain
        self.key = key
    }
    
    var projectedValue: KeychainStored {
        self
    }
    
    var wrappedValue: Wrapped? {
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
        do {
            _ = try keychain.get([
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key,
                kSecReturnAttributes as String: true,
            ], as: [AnyHashable: Any].self)
            return true
        } catch {
            return false
        }
    }
    
    private func set(_ value: Wrapped) {
        do {
            try keychain.add([
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key,
                kSecValueData as String: value.data,
                kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly as String,
            ])
        } catch {
            if let e = error as? OSStatusError, e.status == errSecDuplicateItem {
                try? keychain.update([
                    kSecClass as String: kSecClassGenericPassword,
                    kSecAttrAccount as String: key,
                ], with: [
                    kSecValueData as String: value.data,
                    kSecAttrAccessible as String: kSecAttrAccessibleAfterFirstUnlockThisDeviceOnly as String,
                ])
            }
        }
    }
    
    private func get() -> Wrapped? {
        let data = try? keychain.get([
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecReturnData as String: true,
        ], as: Data.self)
        
        return data.flatMap { try? Wrapped(data: $0) }
    }
    
    private func delete() {
        try? keychain.delete([
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
        ])
    }
}
