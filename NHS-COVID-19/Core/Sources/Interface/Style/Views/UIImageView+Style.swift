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
    public func color(_ color: ColorName) -> Self {
        tintColor = UIColor(color)
        return self
    }
}
