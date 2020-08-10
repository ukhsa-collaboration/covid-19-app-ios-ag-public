//
// Copyright © 2020 NHSX. All rights reserved.
//

import CryptoKit
import Foundation

@propertyWrapper
struct Encrypted<Wrapped: DataConvertible> {
    
    private let dataEncryptor: DataEncrypting
    
    init(_ dataEncryptor: DataEncrypting) {
        self.dataEncryptor = dataEncryptor
    }
    
    var projectedValue: Self {
        self
    }
    
    var wrappedValue: Wrapped? {
        get {
            dataEncryptor.wrappedValue.flatMap { try? Wrapped(data: $0) }
        }
        
        nonmutating set {
            dataEncryptor.wrappedValue = newValue?.data
        }
        
    }
    
    var hasValue: Bool {
        dataEncryptor.hasValue
    }
    
}
