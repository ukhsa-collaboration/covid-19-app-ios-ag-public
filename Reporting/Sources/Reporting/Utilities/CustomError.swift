//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

struct CustomError: Error, CustomStringConvertible {
    var description: String
    
    init(_ description: String) {
        self.description = description
    }
}
