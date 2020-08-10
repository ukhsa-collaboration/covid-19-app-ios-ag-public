//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import UIKit

class ExposureNotificationAppController: AppController {
    
    private let manager = ExposureManager()
    let rootViewController: UIViewController
    
    init() {
        let content = ExposureNotificationViewController(manager: manager)
        rootViewController = UINavigationController(rootViewController: content)
    }
    
}
