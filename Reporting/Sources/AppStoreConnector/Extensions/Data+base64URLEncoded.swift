//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

extension Data {
    
    init?(base64URLEncoded: String) {
        var base64Encoded = base64URLEncoded
            .replacingOccurrences(of: "-", with: "+")
            .replacingOccurrences(of: "_", with: "/")
        
        let overflow = base64Encoded.count % 4
        let padding = (4 - overflow) % 4
        base64Encoded.append(String(repeating: "=", count: padding))
        self.init(base64Encoded: base64Encoded)
    }
    
    func base64URLEncodedString() -> String {
        base64EncodedString()
            .replacingOccurrences(of: "+", with: "-")
            .replacingOccurrences(of: "/", with: "_")
            .replacingOccurrences(of: "=", with: "")
    }
    
}
