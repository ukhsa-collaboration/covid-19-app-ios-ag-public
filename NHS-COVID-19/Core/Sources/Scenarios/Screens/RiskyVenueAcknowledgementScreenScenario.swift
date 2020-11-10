//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Domain
import Integration
import Interface
import UIKit

public class RiskyVenueAcknowledgementScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Risky Venue Isolation Acknowledgement"
    
    public static let days: Double = 14
    public static let acknowledgedNotification: String = "I Understand Tapped"
    public static let exposureFAQTapped = "Exposure FAQ Link tapped"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return ContactCaseAcknowledgementViewController(
                interactor: interactor,
                isolationEndDate: Date(timeIntervalSinceNow: Self.days * 86400),
                type: .riskyVenue
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
        viewController?.showAlert(title: RiskyVenueAcknowledgementScreenScenario.acknowledgedNotification)
    }
    
    func exposureFAQsLinkTapped() {
        viewController?.showAlert(title: RiskyVenueAcknowledgementScreenScenario.exposureFAQTapped)
    }
}
