//
// Copyright © 2020 NHSX. All rights reserved.
//

import UIKit

extension UIViewController {
    public func addFilling(_ child: UIViewController) {
        addChild(child)
        view.addFillingSubview(child.view)
        child.didMove(toParent: self)
    }

    public func addWithAutoLayout(_ child: UIViewController) {
        addChild(child)
        view.addAutolayoutSubview(child.view)
        child.didMove(toParent: self)
    }

    public func remove() {
        guard parent != nil else { return }
        willMove(toParent: nil)
        view.removeFromSuperview()
        removeFromParent()
    }
}
