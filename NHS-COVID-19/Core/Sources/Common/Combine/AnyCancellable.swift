//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine

extension AnyCancellable {
    
    func store(in collection: inout [AnyCancellable]) {
        collection.append(self)
    }
    
}
