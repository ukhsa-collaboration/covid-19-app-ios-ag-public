//
// Copyright © 2020 NHSX. All rights reserved.
//

import Domain
import Integration
import Interface
import UIKit

public protocol EndOfIsolationScreenScenario {
    static var isIndexCase: Bool { get }
}

extension EndOfIsolationScreenScenario {
    public static var kind: ScenarioKind { .screen }
    
    public static var onlineServicesLinkTapped: String { "Online services link tapped" }
    public static var returnHomeTapped: String { "Back to home button tapped" }
    public static var furtherAdviceLinkTapped: String { "Further advice link tapped" }
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return EndOfIsolationViewController(
                interactor: interactor,
                isolationEndDate: Date(timeIntervalSinceNow: 7 * 86400),
                isIndexCase: isIndexCase,
                currentDateProvider: { Date() }
            )
        }
    }
}

public class EndOfIsolationWithAdvisoryScreenScenario: EndOfIsolationScreenScenario, Scenario {
    public static let isIndexCase = true
    public static let name: String = "End of Isolation – Index Case"
}

public class EndOfIsolationWithoutAdvisoryScreenScenario: EndOfIsolationScreenScenario, Scenario {
    public static let isIndexCase = false
    public static let name: String = "End of Isolation – Contact Case"
    
}

private class Interactor: EndOfIsolationViewController.Interacting {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func didTapOnlineServicesLink() {
        viewController?.showAlert(title: EndOfIsolationWithAdvisoryScreenScenario.onlineServicesLinkTapped)
    }
    
    func didTapReturnHome() {
        viewController?.showAlert(title: EndOfIsolationWithAdvisoryScreenScenario.returnHomeTapped)
    }
    
    func didTapFurtherAdviceLink() {
        viewController?.showAlert(title: EndOfIsolationWithAdvisoryScreenScenario.furtherAdviceLinkTapped)
    }
}
