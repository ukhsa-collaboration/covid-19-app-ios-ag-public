//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

@propertyWrapper
struct FileStored<Wrapped: DataConvertible> {
    
    private var storage: FileStorage
    private var name: String
    
    init(storage: FileStorage, name: String) {
        self.storage = storage
        self.name = name
    }
    
    var projectedValue: Self {
        self
    }
    
    var wrappedValue: Wrapped? {
        get {
            guard let data = storage.read(name) else {
                return nil
            }
            return try? Wrapped(data: data)
        }
        
        nonmutating set {
            if let value = newValue {
                storage.save(value.data, to: name)
            } else {
                storage.delete(name)
            }
        }
    }
    
    var hasValue: Bool {
        storage.hasContent(for: name)
    }
    
}
