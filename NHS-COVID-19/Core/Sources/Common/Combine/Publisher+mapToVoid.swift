//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine

public extension Publisher {
    
    func mapToVoid() -> Publishers.Map<Self, Void> {
        map { _ in () }
    }
    
}
