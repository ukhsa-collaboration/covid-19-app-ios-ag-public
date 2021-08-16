//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Domain
import Integration
import Interface
import UIKit

public class ContactCaseNoIsolationFullyVaccinatedScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name = "Contact Case No Isolation Fully Vaccinated"
    
    public static let cancelTapped = "Cancel button tapped"
    public static let bookAFreeTestTapped = "Book a free test button tapped"
    public static let backToHomeTapped = "Back to home button tapped"
    public static let guidanceLinkTapped = "GuidanceLink link tapped"
    public static let commonQuestionsLinkTapped = "CommonQuestions link tapped"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return ContactCaseNoIsolationFullyVaccinatedViewController(interactor: interactor)
        }
    }
}

private class Interactor: ContactCaseNoIsolationFullyVaccinatedViewController.Interacting {
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func didTapCancel() {
        viewController?.showAlert(title: ContactCaseNoIsolationFullyVaccinatedScreenScenario.cancelTapped)
    }
    
    func didTapGuidanceLink() {
        viewController?.showAlert(title: ContactCaseNoIsolationFullyVaccinatedScreenScenario.guidanceLinkTapped)
    }
    
    func didTapBackToHome() {
        viewController?.showAlert(title: ContactCaseNoIsolationFullyVaccinatedScreenScenario.backToHomeTapped)
    }
    
    func didTapBookAFreeTest() {
        viewController?.showAlert(title: ContactCaseNoIsolationFullyVaccinatedScreenScenario.bookAFreeTestTapped)
    }
    
    func didTapCommonQuestionsLink() {
        viewController?.showAlert(title: ContactCaseNoIsolationFullyVaccinatedScreenScenario.commonQuestionsLinkTapped)
    }
}
