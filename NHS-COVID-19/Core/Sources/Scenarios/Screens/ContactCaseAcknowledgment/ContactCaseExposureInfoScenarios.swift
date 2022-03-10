//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Domain
import Integration
import Interface
import UIKit

public class ContactCaseExposureInfoWalesScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name = "EN Exposure Info Wales (actions depend on your vaccination status)"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return ContactCaseExposureInfoWalesViewController(
                interactor: interactor,
                exposureDate: DateComponents(calendar: .gregorian, timeZone: .utc, year: 2021, month: 8, day: 1).date!,
                isIndexCase: false
            )
        }
    }
}

public class ContactCaseExposureInfoEnglandScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name = "EN Exposure Info England (show to an adult)"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return ContactCaseExposureInfoEnglandViewController(
                interactor: interactor,
                exposureDate: DateComponents(calendar: .gregorian, timeZone: .utc, year: 2021, month: 8, day: 1).date!
            )
        }
    }
}

private class Interactor: ContactCaseExposureInfoInteracting {
    public static let continueTapped = "'Continue' button tapped"
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func didTapContinue() {
        viewController?.showAlert(title: Self.continueTapped)
    }
    
}
