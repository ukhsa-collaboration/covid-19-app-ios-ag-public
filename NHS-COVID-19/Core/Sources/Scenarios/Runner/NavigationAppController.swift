//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import UIKit

struct NavigationAppController: AppController {
    var rootViewController: UIViewController
    
    init(makeChild: (UINavigationController) -> UIViewController) {
        let navigationController = UINavigationController()
        navigationController.pushViewController(makeChild(navigationController), animated: false)
        rootViewController = navigationController
    }
}
