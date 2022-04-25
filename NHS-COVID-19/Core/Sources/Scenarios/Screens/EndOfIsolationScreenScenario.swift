//
// Copyright © 2020 NHSX. All rights reserved.
//

import Domain
import Common
import Integration
import Interface
import UIKit

public protocol EndOfIsolationScreenScenario {
    static var isIndexCase: Bool { get }
    static var currentCountry: Country { get }
    static var numberOfIsolationDaysForIndexCase: Int? { get }
}

extension EndOfIsolationScreenScenario {
    public static var kind: ScenarioKind { .screen }
    
    public static var onlineServicesLinkTapped: String { "Online services link tapped" }
    public static var returnHomeTapped: String { "Back to home button tapped" }
    public static var primaryLinkTapped: String { "Primary link button tapped" }
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return EndOfIsolationViewController(
                interactor: interactor,
                isolationEndDate: Date(timeIntervalSinceNow: 7 * 86400),
                isIndexCase: isIndexCase,
                numberOfIsolationDaysForIndexCase: numberOfIsolationDaysForIndexCase,
                currentDateProvider: DateProvider(),
                currentCountry: currentCountry
            )
        }
    }
}

public class EndOfIsolationForIndexCaseEnglandScreenScenario: EndOfIsolationScreenScenario, Scenario {
    public static let isIndexCase = true
    public static let currentCountry = Country.england
    public static let numberOfIsolationDaysForIndexCase: Int? = 6
    public static let name: String = "End of Isolation – Index Case (England)"
}

public class EndOfIsolationForContactCaseEnglandScreenScenario: EndOfIsolationScreenScenario, Scenario {
    public static let isIndexCase = false
    public static let currentCountry = Country.england
    public static let numberOfIsolationDaysForIndexCase: Int? = nil
    public static let name: String = "End of Isolation – Contact Case (England)"
    
}

public class EndOfIsolationForIndexCaseWalesScreenScenario: EndOfIsolationScreenScenario, Scenario {
    public static let isIndexCase = true
    public static let currentCountry = Country.wales
    public static let numberOfIsolationDaysForIndexCase: Int? = 6
    public static let name: String = "End of Isolation – Index Case (Wales)"
}

public class EndOfIsolationForContactCaseWalesScreenScenario: EndOfIsolationScreenScenario, Scenario {
    public static let isIndexCase = false
    public static let currentCountry = Country.wales
    public static let numberOfIsolationDaysForIndexCase: Int? = nil
    public static let name: String = "End of Isolation – Contact Case (Wales)"
    
}

private class Interactor: EndOfIsolationViewController.Interacting {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func didTapOnlineServicesLink() {
        viewController?.showAlert(title: EndOfIsolationForIndexCaseWalesScreenScenario.onlineServicesLinkTapped)
    }
    
    func didTapReturnHome() {
        viewController?.showAlert(title: EndOfIsolationForIndexCaseWalesScreenScenario.returnHomeTapped)
    }
    
    func didTapPrimaryLinkButton() {
        viewController?.showAlert(title: EndOfIsolationForIndexCaseWalesScreenScenario.primaryLinkTapped)
    }
}
