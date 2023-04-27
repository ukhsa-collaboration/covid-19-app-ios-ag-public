//
// Copyright © 2020 NHSX. All rights reserved.
//

import UIKit

extension UIImageView {

    @discardableResult
    public func styleAsDecoration() -> Self {
        accessibilityElementsHidden = true
        contentMode = .scaleAspectFit
        return self
    }

    @discardableResult
    public func styleAsAccessibleDecoration(_ accessibility: String) -> Self {
        isAccessibilityElement = true
        accessibilityElementsHidden = false
        contentMode = .scaleAspectFit
        accessibilityTraits = .image
        accessibilityLabel = accessibility
        return self
    }

    @discardableResult
    public func color(_ color: ColorName) -> Self {
        tintColor = UIColor(color)
        return self
    }
}
