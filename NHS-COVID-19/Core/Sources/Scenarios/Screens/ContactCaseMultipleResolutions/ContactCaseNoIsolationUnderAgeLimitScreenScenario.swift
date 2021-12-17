//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Domain
import Integration
import Interface
import UIKit

public class ContactCaseNoIsolationUnderAgeLimitEnglandScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name = "Contact Case No Isolation Under 18 (England)"
    
    public static let cancelTapped = "Cancel button tapped"
    public static let bookAFreeTestTapped = "Book a free test button tapped"
    public static let backToHomeTapped = "Back to home button tapped"
    public static let guidanceLinkTapped = "GuidanceLink link tapped"
    public static let commonQuestionsLinkTapped = "CommonQuestions link tapped"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = EnglandInteractor(viewController: parent)
            return ContactCaseNoIsolationUnderAgeLimitEnglandViewController(interactor: interactor)
        }
    }
}

private class EnglandInteractor: ContactCaseNoIsolationUnderAgeLimitInteracting {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func didTapCancel() {
        viewController?.showAlert(title: ContactCaseNoIsolationUnderAgeLimitEnglandScreenScenario.cancelTapped)
    }
    
    func didTapGuidanceLink() {
        viewController?.showAlert(title: ContactCaseNoIsolationUnderAgeLimitEnglandScreenScenario.guidanceLinkTapped)
    }
    
    func didTapBackToHome() {
        viewController?.showAlert(title: ContactCaseNoIsolationUnderAgeLimitEnglandScreenScenario.backToHomeTapped)
    }
    
    func didTapBookAFreeTest() {
        viewController?.showAlert(title: ContactCaseNoIsolationUnderAgeLimitEnglandScreenScenario.bookAFreeTestTapped)
    }
    
    func didTapCommonQuestionsLink() {
        viewController?.showAlert(title: ContactCaseNoIsolationUnderAgeLimitEnglandScreenScenario.commonQuestionsLinkTapped)
    }
}

public class ContactCaseNoIsolationUnderAgeLimitWalesScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name = "Contact Case No Isolation Under 18 (Wales)"
    
    public static let cancelTapped = "Cancel button tapped"
    public static let bookAFreeTestTapped = "Book a free test button tapped"
    public static let backToHomeTapped = "Back to home button tapped"
    public static let guidanceLinkTapped = "GuidanceLink link tapped"
    public static let commonQuestionsLinkTapped = "CommonQuestions link tapped"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = WalesInteractor(viewController: parent)
            return ContactCaseNoIsolationUnderAgeLimitWalesViewController(interactor: interactor, secondTestAdviceDate: GregorianDay(year: 2021, month: 12, day: 23).startDate(in: .utc))
        }
    }
}

private class WalesInteractor: ContactCaseNoIsolationUnderAgeLimitInteracting {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func didTapCancel() {
        viewController?.showAlert(title: ContactCaseNoIsolationUnderAgeLimitWalesScreenScenario.cancelTapped)
    }
    
    func didTapGuidanceLink() {
        viewController?.showAlert(title: ContactCaseNoIsolationUnderAgeLimitWalesScreenScenario.guidanceLinkTapped)
    }
    
    func didTapBackToHome() {
        viewController?.showAlert(title: ContactCaseNoIsolationUnderAgeLimitWalesScreenScenario.backToHomeTapped)
    }
    
    func didTapBookAFreeTest() {
        viewController?.showAlert(title: ContactCaseNoIsolationUnderAgeLimitWalesScreenScenario.bookAFreeTestTapped)
    }
    
    func didTapCommonQuestionsLink() {
        viewController?.showAlert(title: ContactCaseNoIsolationUnderAgeLimitWalesScreenScenario.commonQuestionsLinkTapped)
    }
}
