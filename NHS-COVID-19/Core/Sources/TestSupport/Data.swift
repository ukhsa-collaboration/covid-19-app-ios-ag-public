//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

public extension Data {
    
    func normalizingJSON() -> Data {
        guard let json = try? JSONSerialization.jsonObject(with: self, options: []) else {
            return self
        }
        
        return try! JSONSerialization.data(withJSONObject: json, options: [.prettyPrinted, .sortedKeys])
    }
    
}

public extension String {
    
    func normalizedJSON() -> Data {
        data(using: .utf8)!.normalizingJSON()
    }
    
}
