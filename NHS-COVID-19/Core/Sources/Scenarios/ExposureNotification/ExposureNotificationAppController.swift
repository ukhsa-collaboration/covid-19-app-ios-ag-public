//
// Copyright © 2021 DHSC. All rights reserved.
//

import Integration
import Interface
import UIKit

@available(iOSApplicationExtension, unavailable)
class ExposureNotificationAppController: AppController {

    private let manager = ExposureManager()
    let rootViewController: UIViewController

    init() {
        let content = ExposureNotificationViewController(manager: manager)
        rootViewController = UINavigationController(rootViewController: content)
    }

}
