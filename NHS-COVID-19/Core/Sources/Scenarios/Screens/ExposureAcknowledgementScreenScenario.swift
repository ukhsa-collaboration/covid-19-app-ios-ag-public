//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Domain
import Integration
import Interface
import UIKit

public class ExposureAcknowledgementScreenNoDCTScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Exposure Notification Acknowledgement (No DCT)"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return ContactCaseAcknowledgementViewController(
                interactor: interactor,
                isolationEndDate: Date(timeIntervalSinceNow: 14 * 86400),
                showDailyContactTesting: false
            )
        }
    }
}

public class ExposureAcknowledgementScreenWithDCTScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Exposure Notification Acknowledgement (DCT Available)"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return ContactCaseAcknowledgementViewController(
                interactor: interactor,
                isolationEndDate: Date(timeIntervalSinceNow: 14 * 86400),
                showDailyContactTesting: true
            )
        }
    }
}

private class Interactor: ContactCaseAcknowledgementViewController.Interacting {
    
    let acknowledgedNotification: String = "I Understand Tapped"
    let exposureFAQTapped = "Exposure FAQ Link tapped"
    let dailyContactTestingLinkTapped = "Daily Contact Testing link tapped"
    
    func didTapOnlineLink() {}
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func acknowledge() {
        viewController?.showAlert(title: acknowledgedNotification)
    }
    
    func exposureFAQsLinkTapped() {
        viewController?.showAlert(title: exposureFAQTapped)
    }
    
    func didTapDailyContactTesting() {
        viewController?.showAlert(title: dailyContactTestingLinkTapped)
    }
    
}
