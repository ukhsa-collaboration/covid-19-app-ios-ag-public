//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Domain
import Integration
import Interface
import UIKit

public class ContactCaseNoIsolationMedicallyExemptScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name = "Contact Case No Isolation Medically Exempt"
    
    public static let cancelTapped = "Cancel button tapped"
    public static let bookAFreeTestTapped = "Book a free test button tapped"
    public static let backToHomeTapped = "Back to home button tapped"
    public static let guidanceLinkTapped = "GuidanceLink link tapped"
    public static let commonQuestionsLinkTapped = "CommonQuestions link tapped"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return ContactCaseNoIsolationMedicallyExemptViewController(interactor: interactor)
        }
    }
}

private class Interactor: ContactCaseNoIsolationMedicallyExemptViewController.Interacting {
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func didTapCancel() {
        viewController?.showAlert(title: ContactCaseNoIsolationMedicallyExemptScreenScenario.cancelTapped)
    }
    
    func didTapGuidanceLink() {
        viewController?.showAlert(title: ContactCaseNoIsolationMedicallyExemptScreenScenario.guidanceLinkTapped)
    }
    
    func didTapBackToHome() {
        viewController?.showAlert(title: ContactCaseNoIsolationMedicallyExemptScreenScenario.backToHomeTapped)
    }
    
    func didTapBookAFreeTest() {
        viewController?.showAlert(title: ContactCaseNoIsolationMedicallyExemptScreenScenario.bookAFreeTestTapped)
    }
    
    func didTapCommonQuestionsLink() {
        viewController?.showAlert(title: ContactCaseNoIsolationMedicallyExemptScreenScenario.commonQuestionsLinkTapped)
    }
}
