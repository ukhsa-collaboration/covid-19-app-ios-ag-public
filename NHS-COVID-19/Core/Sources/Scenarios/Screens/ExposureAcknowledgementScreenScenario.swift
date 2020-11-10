//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Domain
import Integration
import Interface
import UIKit

public class ExposureAcknowledgementScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Exposure Notification Acknowledgement"
    
    public static let acknowledgedNotification: String = "I Understand Tapped"
    public static let exposureFAQTapped = "Exposure FAQ Link tapped"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return ContactCaseAcknowledgementViewController(
                interactor: interactor,
                isolationEndDate: Date(timeIntervalSinceNow: 14 * 86400),
                type: .exposureDetection
            )
        }
    }
}

private class Interactor: ContactCaseAcknowledgementViewController.Interacting {
    func didTapOnlineLink() {}
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func acknowledge() {
        viewController?.showAlert(title: ExposureAcknowledgementScreenScenario.acknowledgedNotification)
    }
    
    func exposureFAQsLinkTapped() {
        viewController?.showAlert(title: RiskyVenueAcknowledgementScreenScenario.exposureFAQTapped)
    }
}
