//
// Copyright © 2020 NHSX. All rights reserved.
//

import BackgroundTasks
import Common
import Domain
import Integration
import Interface
import UIKit

public class BackgroundTaskScenario: Scenario {
    public static let name = "Exposure Notification Background Task"
    public static let kind = ScenarioKind.prototype
    
    private static let exposureNotificationManager: MockExposureNotificationManager = {
        let exposureNotificationManager = MockExposureNotificationManager()
        exposureNotificationManager.instanceAuthorizationStatus = .authorized
        return exposureNotificationManager
    }()
    
    static var appController: AppController {
        BackgroundTaskAppController()
    }
}

private struct BackgroundTaskAppController: AppController {
    var rootViewController: UIViewController {
        backgroundTaskViewController
    }
    
    private let backgroundTaskViewController = BackgroundTaskViewController()
    
    func performBackgroundTask(task: BackgroundTask) {
        backgroundTaskViewController.showAlert(title: "Background task has been launched")
        task.setTaskCompleted(success: true)
    }
}

private class BackgroundTaskViewController: UIViewController {
    private static var identifier: String {
        guard let identifier = BackgroundTaskIdentifiers(in: Bundle.main).exposureNotification else {
            preconditionFailure("Missing background task exposure notification identifier")
        }
        return identifier
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let view = self.view!
        view.styleAsScreenBackground(with: traitCollection)
        view.insetsLayoutMarginsFromSafeArea = true
        
        let titleLabel = UILabel()
        titleLabel.styleAsHeading()
        titleLabel.text = "Background Task"
        
        let instructionLabel = UILabel()
        instructionLabel.styleAsBody()
        instructionLabel.text = "To manually trigger a background notification, run on a real device, pause debugging, enter the following into the debug console, then resume debugging:"
        
        let commandLabel = UILabel()
        commandLabel.styleAsBody()
        commandLabel.text = """
        e -l objc -- (void)[[BGTaskScheduler sharedScheduler] _simulateLaunchForTaskWithIdentifier:@"uk.nhs.covid19.internal.exposure-notification"]
        """
        
        let button = UIButton()
        button.styleAsPrimary()
        button.setTitle("Schedule Task", for: .normal)
        button.addTarget(self, action: #selector(scheduleTask), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [
            titleLabel, instructionLabel, commandLabel, button,
        ])
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = .standardSpacing
        view.addAutolayoutSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            stackView.topAnchor.constraint(greaterThanOrEqualTo: view.layoutMarginsGuide.topAnchor),
            stackView.centerYAnchor.constraint(equalTo: view.layoutMarginsGuide.centerYAnchor),
        ])
    }
    
    @objc private func scheduleTask() {
        let taskRequest = BGProcessingTaskRequest(identifier: Self.identifier)
        taskRequest.requiresNetworkConnectivity = true
        try? BGTaskScheduler.shared.submit(taskRequest)
        
        showAlert(title: "Scheduled task successfully")
    }
    
}
