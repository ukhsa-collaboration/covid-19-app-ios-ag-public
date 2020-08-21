//
// Copyright © 2020 NHSX. All rights reserved.
//

import UIKit

extension UIControl {
    func addTarget(_ target: Any?, action: Selector) {
        addTarget(target, action: action, for: .touchUpInside)
    }
}
