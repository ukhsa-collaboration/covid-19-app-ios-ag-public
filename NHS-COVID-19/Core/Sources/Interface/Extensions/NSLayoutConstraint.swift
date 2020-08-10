//
// Copyright © 2020 NHSX. All rights reserved.
//

import UIKit

extension NSLayoutConstraint {
    
    func withPriority(_ priority: UILayoutPriority) -> NSLayoutConstraint {
        self.priority = priority
        return self
    }
    
}
