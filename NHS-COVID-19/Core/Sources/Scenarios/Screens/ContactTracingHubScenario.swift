//
// Copyright © 2021 NHSX. All rights reserved.
//

import Integration
import Interface
import UIKit
import Combine

public class ContactTracingHubScenario: Scenario {
    public static let name = "Contact Tracing Hub"
    public static let kind = ScenarioKind.screen
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            let exposureNotificationsEnabled = CurrentValueSubject<Bool, Never>(true).property(initialValue: true)
            let userNotificationsEnabled = CurrentValueSubject<Bool, Never>(true).property(initialValue: true)
            return ContactTracingHubViewController(
                interactor,
                exposureNotificationsEnabled: exposureNotificationsEnabled,
                exposureNotificationsToggleAction: { enabled in
                    print("Exposure notifications toggled to \(enabled)")
                },
                userNotificationsEnabled: userNotificationsEnabled
            )
        }
    }
}

private class Interactor: ContactTracingHubViewController.Interacting {
    
    private weak var viewController: UIViewController?
    
    func scheduleReminderNotification(reminderIn: ExposureNotificationReminderIn) {
        viewController?.showAlert(title: "Schedule reminder in \(reminderIn.rawValue)hrs")
    }
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
}
