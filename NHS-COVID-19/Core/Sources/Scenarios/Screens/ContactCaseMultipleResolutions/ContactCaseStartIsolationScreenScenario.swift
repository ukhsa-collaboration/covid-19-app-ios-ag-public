//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Domain
import Integration
import Interface
import UIKit

public class ContactCaseStartIsolationScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name = "Contact Case Start Isolation"
    
    public static let numberOfDays = 10
    public static let exposureDate = Date(timeIntervalSinceNow: -86400)
    public static let cancelTapped = "Cancel button tapped"
    public static let bookAFreeTestTapped = "Book a free test button tapped"
    public static let backToHomeTapped = "Back to home button tapped"
    public static let guidanceLinkTapped = "GuidanceLink link tapped"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return ContactCaseStartIsolationViewController(interactor: interactor, isolationEndDate: Date(timeIntervalSinceNow: Double(Self.numberOfDays) * 86400), exposureDate: exposureDate, secondTestAdviceDate: nil, isolationPeriod: 11)
        }
    }
}

private class Interactor: ContactCaseStartIsolationViewController.Interacting {
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func didTapCancel() {
        viewController?.showAlert(title: ContactCaseStartIsolationScreenScenario.cancelTapped)
    }
    
    func didTapGuidanceLink() {
        viewController?.showAlert(title: ContactCaseStartIsolationScreenScenario.guidanceLinkTapped)
    }
    
    func didTapBackToHome() {
        viewController?.showAlert(title: ContactCaseStartIsolationScreenScenario.backToHomeTapped)
    }
    
    func didTapBookAFreeTest() {
        viewController?.showAlert(title: ContactCaseStartIsolationScreenScenario.bookAFreeTestTapped)
    }
}
