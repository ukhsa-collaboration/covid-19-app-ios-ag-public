//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import UIKit

public class BaseNavigationController: UINavigationController {

    public init() {
        super.init(nibName: nil, bundle: nil)

        view.applySemanticContentAttribute()
    }

    override public init(rootViewController: UIViewController) {
        super.init(rootViewController: rootViewController)

        view.applySemanticContentAttribute()
    }

    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func pushViewController(
        _ viewController: UIViewController,
        animated: Bool
    ) {
        // The back button will be localized for the parent vc every time we push a new view controller.
        // This may seem a little hacky but it avoid bugs where we forget to localize the back button when creating new view controllers.
        viewControllers.last?.navigationItem.backBarButtonItem = UIBarButtonItem(title: localize(.back), style: .plain, target: nil, action: nil)
        super.pushViewController(viewController, animated: animated)
    }
}
