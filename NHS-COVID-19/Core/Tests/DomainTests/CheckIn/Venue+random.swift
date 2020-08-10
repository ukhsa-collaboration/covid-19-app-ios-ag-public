//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
@testable import Domain

extension Venue {
    
    static func random() -> Venue {
        Venue(id: .random(), organisation: .random())
    }
    
}
