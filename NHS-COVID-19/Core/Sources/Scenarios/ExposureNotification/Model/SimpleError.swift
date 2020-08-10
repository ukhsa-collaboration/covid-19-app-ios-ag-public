//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

struct SimpleError: Error, CustomStringConvertible {
    var description: String
    
    init(_ description: String) {
        self.description = description
    }
}
