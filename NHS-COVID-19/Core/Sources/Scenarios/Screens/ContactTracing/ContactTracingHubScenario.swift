//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Integration
import Interface
import UIKit

public class ContactTracingHubScenario: Scenario {
    public static let name = "Contact Tracing Hub"
    public static let kind = ScenarioKind.screen
    
    public static let adviceWhenDoNotPauseCTAlertTitle = "Advice when should not pause CT tapped"
    
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
    private var cancellable: AnyCancellable?
    
    func scheduleReminderNotification(reminderIn: ExposureNotificationReminderIn) {
        print("Schedule reminder in \(reminderIn.rawValue)hrs")
    }
    
    func didTapAdviceWhenDoNotPauseCTButton() {
        viewController?.showAlert(title: ContactTracingHubScenario.adviceWhenDoNotPauseCTAlertTitle)
    }
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
}
