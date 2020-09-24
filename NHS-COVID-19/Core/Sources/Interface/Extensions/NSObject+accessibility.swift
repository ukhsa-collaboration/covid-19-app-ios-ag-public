//
// Copyright © 2020 NHSX. All rights reserved.
//

import UIKit

extension NSObject {
    @discardableResult
    func isAccessibilityElement(_ isAccessibilityElement: Bool) -> Self {
        self.isAccessibilityElement = isAccessibilityElement
        return self
    }
    
    @discardableResult
    func accessibilityTraits(_ accessibilityTraits: UIAccessibilityTraits) -> Self {
        self.accessibilityTraits = accessibilityTraits
        return self
    }
    
    @discardableResult
    func accessibilityLabel(_ accessibilityLabel: String) -> Self {
        self.accessibilityLabel = accessibilityLabel
        return self
    }
}
