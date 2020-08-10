//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import Logging

extension Logger.Metadata {
    
    public init(dictionary: [AnyHashable: Any]) {
        self.init(uniqueKeysWithValues: dictionary
            .map { key, value in
                ("\(key)", Logger.MetadataValue(describing: value))
            }
        )
    }
    
}

extension Logger.MetadataValue {
    
    public init(describing value: Any) {
        switch value {
        case let string as String:
            self = .string(string)
        case let array as [Any]:
            self = .array(array.map { Logger.MetadataValue(describing: $0) })
        case let dictionary as [AnyHashable: Any]:
            self = .dictionary(Logger.Metadata(dictionary: dictionary))
        case let convertible as CustomStringConvertible:
            self = .stringConvertible(convertible)
        default:
            self = .string(String(describing: value))
        }
    }
    
}
