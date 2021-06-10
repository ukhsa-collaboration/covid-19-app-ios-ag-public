//
// Copyright © 2021 DHSC. All rights reserved.
//

import Integration
import Interface
import UIKit

public class BookAFollowUpTestScreenScenario: Scenario {
    
    public enum AlertTitle {
        public static let closeButton = "Close button tapped"
        public static let onlineServicesLink = "Advice link tapped"
        public static let primaryButton = "Book a follow-up test button tapped"
    }
    
    public static let name = "Book a follow-up test"
    public static let kind = ScenarioKind.screen
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return BookAFollowUpTestViewController(interactor: interactor)
        }
    }
}

private class Interactor: BookAFollowUpTestViewController.Interacting {
    private typealias AlertTitle = BookAFollowUpTestScreenScenario.AlertTitle
    
    var didTapOnlineServicesLink: () -> Void
    var didTapPrimaryButton: () -> Void
    var didTapCancel: () -> Void
    
    init(viewController: UIViewController) {
        didTapOnlineServicesLink = { [weak viewController] in
            viewController?.showAlert(title: AlertTitle.onlineServicesLink)
        }
        
        didTapPrimaryButton = { [weak viewController] in
            viewController?.showAlert(title: AlertTitle.primaryButton)
        }
        
        didTapCancel = { [weak viewController] in
            viewController?.showAlert(title: AlertTitle.closeButton)
        }
    }
}
