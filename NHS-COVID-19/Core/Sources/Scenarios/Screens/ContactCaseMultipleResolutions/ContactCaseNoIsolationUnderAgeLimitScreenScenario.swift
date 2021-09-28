//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Domain
import Integration
import Interface
import UIKit

public class ContactCaseNoIsolationUnderAgeLimitScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name = "Contact Case No Isolation Under Age Limit"
    
    public static let cancelTapped = "Cancel button tapped"
    public static let bookAFreeTestTapped = "Book a free test button tapped"
    public static let backToHomeTapped = "Back to home button tapped"
    public static let guidanceLinkTapped = "GuidanceLink link tapped"
    public static let commonQuestionsLinkTapped = "CommonQuestions link tapped"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return ContactCaseNoIsolationUnderAgeLimitViewController(interactor: interactor, secondTestAdviceDate: nil)
        }
    }
}

private class Interactor: ContactCaseNoIsolationUnderAgeLimitViewController.Interacting {
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func didTapCancel() {
        viewController?.showAlert(title: ContactCaseNoIsolationUnderAgeLimitScreenScenario.cancelTapped)
    }
    
    func didTapGuidanceLink() {
        viewController?.showAlert(title: ContactCaseNoIsolationUnderAgeLimitScreenScenario.guidanceLinkTapped)
    }
    
    func didTapBackToHome() {
        viewController?.showAlert(title: ContactCaseNoIsolationUnderAgeLimitScreenScenario.backToHomeTapped)
    }
    
    func didTapBookAFreeTest() {
        viewController?.showAlert(title: ContactCaseNoIsolationUnderAgeLimitScreenScenario.bookAFreeTestTapped)
    }
    
    func didTapCommonQuestionsLink() {
        viewController?.showAlert(title: ContactCaseNoIsolationUnderAgeLimitScreenScenario.commonQuestionsLinkTapped)
    }
}
