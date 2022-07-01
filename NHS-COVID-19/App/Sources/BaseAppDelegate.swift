//
// Copyright © 2021 DHSC. All rights reserved.
//

import BackgroundTasks
import Domain
import Integration
import Logging
import UIKit

class BaseAppDelegate: UIResponder, UIApplicationDelegate, UNUserNotificationCenterDelegate {
    private static var identifier: String {
        guard let identifier = BackgroundTaskIdentifiers(in: Bundle.main).exposureNotification else {
            preconditionFailure("Missing background task exposure notification identifier")
        }
        return identifier
    }

    private lazy var appController: AppController! = self.makeAppController()
    var window: UIWindow?

    var backgroundTaskScheduler: BackgroundTaskScheduling {
        BGTaskScheduler.shared
    }

    func makeAppController() -> AppController {
        preconditionFailure("Subclasses must override")
    }

    func makeLogHandler(label: String) -> LogHandler {
        preconditionFailure("Subclasses must override")
    }

    func application(_ application: UIApplication, didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?) -> Bool {
        LoggingSystem.bootstrap(makeLogHandler(label:))

        #if targetEnvironment(simulator)
        print("Documents: \(FileManager.default.urls(for: .documentDirectory, in: .userDomainMask))")
        #endif

        backgroundTaskScheduler.register(forTaskWithIdentifier: Self.identifier, using: .main) { [weak self] task in
            self?.appController?.performBackgroundTask(task: task)
        }

        let window = UIWindow(frame: UIScreen.main.bounds)
        window.makeKeyAndVisible()
        window.rootViewController = appController?.rootViewController
        self.window = window

        let notificationCenter = UNUserNotificationCenter.current()
        notificationCenter.delegate = self
        UserNotificationActionRegistration.registerUserNotificationActions(notificationCenter: notificationCenter)

        return true
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        completionHandler([.alert, .badge, .sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        appController?.handleUserNotificationResponse(response, completionHandler: completionHandler)
    }

}
