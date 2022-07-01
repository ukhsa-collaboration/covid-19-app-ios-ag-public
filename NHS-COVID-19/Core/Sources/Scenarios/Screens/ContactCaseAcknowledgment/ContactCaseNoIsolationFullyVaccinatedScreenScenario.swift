//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Domain
import Integration
import Interface
import UIKit

public class ContactCaseNoIsolationFullyVaccinatedEnglandScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name = "Contact Case No Isolation Fully Vaxxed (England)"

    public static let cancelTapped = "Cancel button tapped"
    public static let bookAFreeTestTapped = "Book a free test button tapped"
    public static let backToHomeTapped = "Back to home button tapped"
    public static let guidanceLinkTapped = "GuidanceLink link tapped"
    public static let commonQuestionsLinkTapped = "CommonQuestions link tapped"
    public static let readGuidanceLinkTapped = "ReadGuidance link tapped"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = EnglandInteractor(viewController: parent)
            return ContactCaseNoIsolationFullyVaccinatedEnglandViewController(interactor: interactor)
        }
    }
}

private class EnglandInteractor: ContactCaseNoIsolationFullyVaccinatedInteracting {
    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func didTapCancel() {
        viewController?.showAlert(title: ContactCaseNoIsolationFullyVaccinatedEnglandScreenScenario.cancelTapped)
    }

    func didTapGuidanceLink() {
        viewController?.showAlert(title: ContactCaseNoIsolationFullyVaccinatedEnglandScreenScenario.guidanceLinkTapped)
    }

    func didTapBackToHome() {
        viewController?.showAlert(title: ContactCaseNoIsolationFullyVaccinatedEnglandScreenScenario.backToHomeTapped)
    }

    func didTapBookAFreeTest() {
        viewController?.showAlert(title: ContactCaseNoIsolationFullyVaccinatedEnglandScreenScenario.bookAFreeTestTapped)
    }

    func didTapCommonQuestionsLink() {
        viewController?.showAlert(title: ContactCaseNoIsolationFullyVaccinatedEnglandScreenScenario.commonQuestionsLinkTapped)
    }

    func didTapReadGuidanceForContacts() {
        viewController?.showAlert(title: ContactCaseNoIsolationFullyVaccinatedEnglandScreenScenario.readGuidanceLinkTapped)
    }
}

public class ContactCaseNoIsolationFullyVaccinatedWalesScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name = "Contact Case No Isolation Fully Vaxxed (Wales)"

    public static let cancelTapped = "Cancel button tapped"
    public static let bookAFreeTestTapped = "Book a free test button tapped"
    public static let backToHomeTapped = "Back to home button tapped"
    public static let guidanceLinkTapped = "GuidanceLink link tapped"
    public static let commonQuestionsLinkTapped = "CommonQuestions link tapped"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = WalesInteractor(viewController: parent)
            return ContactCaseNoIsolationFullyVaccinatedWalesViewController(interactor: interactor, secondTestAdviceDate: GregorianDay(year: 2021, month: 12, day: 23).startDate(in: .utc))
        }
    }
}

private class WalesInteractor: ContactCaseNoIsolationFullyVaccinatedInteracting {
    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func didTapCancel() {
        viewController?.showAlert(title: ContactCaseNoIsolationFullyVaccinatedWalesScreenScenario.cancelTapped)
    }

    func didTapGuidanceLink() {
        viewController?.showAlert(title: ContactCaseNoIsolationFullyVaccinatedWalesScreenScenario.guidanceLinkTapped)
    }

    func didTapBackToHome() {
        viewController?.showAlert(title: ContactCaseNoIsolationFullyVaccinatedWalesScreenScenario.backToHomeTapped)
    }

    func didTapBookAFreeTest() {
        viewController?.showAlert(title: ContactCaseNoIsolationFullyVaccinatedWalesScreenScenario.bookAFreeTestTapped)
    }

    func didTapCommonQuestionsLink() {
        viewController?.showAlert(title: ContactCaseNoIsolationFullyVaccinatedWalesScreenScenario.commonQuestionsLinkTapped)
    }

    func didTapReadGuidanceForContacts() {
        assertionFailure("Should not be able to tap England guidance button from the Wales screen.")
    }
}
