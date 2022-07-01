//
// Copyright © 2021 DHSC. All rights reserved.
//

import Domain
import Integration
import Interface
import UIKit

public class DiscardedSymptomsAfterPositiveScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Self-Diagnosis after Positive - Discarded"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return SelfDiagnosisAfterPositiveTestIsolatingViewController(interactor: interactor, symptomState: .discardSymptoms)
        }
    }
}

public class NoSymptomsAfterPositiveScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Self-Diagnosis after Positive - No Symptoms"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return SelfDiagnosisAfterPositiveTestIsolatingViewController(interactor: interactor, symptomState: .noSymptoms)
        }
    }
}

public struct SelfDiagnosisAfterPositiveTestIsolatingViewControllerScenario {
    public static let returnHomeTapped: String = "Return home button tapped"
    public static let nhs111LinkTapped: String = "NHS 111 link tapped"
}

private class Interactor: SelfDiagnosisAfterPositiveTestIsolatingViewController.Interacting {

    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func didTapReturnHome() {
        viewController?.showAlert(title: SelfDiagnosisAfterPositiveTestIsolatingViewControllerScenario.returnHomeTapped)
    }

    func didTapNHS111Link() {
        viewController?.showAlert(title: SelfDiagnosisAfterPositiveTestIsolatingViewControllerScenario.nhs111LinkTapped)
    }
}
