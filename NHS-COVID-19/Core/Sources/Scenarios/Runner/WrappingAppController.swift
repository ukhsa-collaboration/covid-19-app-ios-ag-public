//
// Copyright © 2020 NHSX. All rights reserved.
//

import Domain
import Integration
import Interface
import UIKit

class WrappingAppController: AppController {
    let rootViewController = UIViewController()
    
    var content: AppController? {
        didSet {
            oldValue?.rootViewController.remove()
            if let content = content {
                rootViewController.addFilling(content.rootViewController)
            }
        }
    }
    
    func performBackgroundTask(task: BackgroundTask) {
        content?.performBackgroundTask(task: task)
    }
    
    func handleUserNotificationResponse(_ response: UNNotificationResponse, completionHandler: @escaping () -> Void) {
        content?.handleUserNotificationResponse(response, completionHandler: completionHandler)
    }
}
