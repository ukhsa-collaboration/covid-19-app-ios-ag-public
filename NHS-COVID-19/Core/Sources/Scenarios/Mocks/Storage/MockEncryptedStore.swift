//
// Copyright © 2020 NHSX. All rights reserved.
//

import Domain
import Foundation

public class MockEncryptedStore: EncryptedStoring {

    public var stored = [String: Data]()

    public init() {}

    public func dataEncryptor(_ name: String) -> DataEncrypting {
        MockDataEncryptor(store: self, name: name)
    }

}

private struct MockDataEncryptor: DataEncrypting {

    var store: MockEncryptedStore
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
