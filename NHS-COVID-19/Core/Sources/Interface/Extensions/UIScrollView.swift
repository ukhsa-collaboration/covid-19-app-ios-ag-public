//
// Copyright © 2021 DHSC. All rights reserved.
//

import UIKit

extension UIScrollView {
    func scroll(to view: UIView) {
        guard let parentView = view.superview else { return }

        // Get subview's start point relative to scrollView
        let viewStartPoint = parentView.convert(view.frame.origin, to: self)

        scrollRectToVisible(CGRect(x: 0, y: viewStartPoint.y, width: 1, height: frame.height), animated: true)
    }
}
