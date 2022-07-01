//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Integration
import Interface
import UIKit

protocol CommonContactTracingHubScenario: Scenario {
    static var userNotificationsAuthorized: Bool { get }
}

extension CommonContactTracingHubScenario {

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            let exposureNotificationsEnabled = CurrentValueSubject<Bool, Never>(true).property(initialValue: true)
            let userNotificationsEnabled = CurrentValueSubject<Bool, Never>(userNotificationsAuthorized).property(initialValue: userNotificationsAuthorized)
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

public enum ContactTracingHubAlertTitle {
    public static let adviceWhenDoNotPauseCT = "Advice when should not pause CT tapped"
}

public class ContactTracingHubUserNotificationsAuthorizedScenario: CommonContactTracingHubScenario {
    public static let name = "Contact Tracing Hub - User Notifications Authorized"
    public static let kind = ScenarioKind.screen
    static let userNotificationsAuthorized = true
}

public class ContactTracingHubUserNotificationsNotAuthorizedScenario: CommonContactTracingHubScenario {
    public static let name = "Contact Tracing Hub - User Notifications Not Authorized"
    public static let kind = ScenarioKind.screen
    static let userNotificationsAuthorized = false
}

private class Interactor: ContactTracingHubViewController.Interacting {

    private weak var viewController: UIViewController?
    private var cancellable: AnyCancellable?

    func scheduleReminderNotification(reminderIn: ExposureNotificationReminderIn) {
        print("Schedule reminder in \(reminderIn.rawValue)hrs")
    }

    func didTapAdviceWhenDoNotPauseCTButton() {
        viewController?.showAlert(title: ContactTracingHubAlertTitle.adviceWhenDoNotPauseCT)
    }

    init(viewController: UIViewController) {
        self.viewController = viewController
    }
}
