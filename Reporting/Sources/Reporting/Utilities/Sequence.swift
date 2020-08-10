//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

extension Sequence {
    
    func count(where isIncluded: (Element) -> Bool) -> Int {
        lazy.filter(isIncluded).count
    }
    
}
