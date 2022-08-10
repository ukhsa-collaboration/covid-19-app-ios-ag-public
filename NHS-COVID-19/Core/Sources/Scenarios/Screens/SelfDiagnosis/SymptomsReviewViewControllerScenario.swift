//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Domain
import Integration
import Interface
import UIKit

public class SymptomsReviewViewControllerScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Self-Diagnosis - Symptoms Review"

    public static var deniedForFeverish = "A runny nose"
    public static var confirmedForCough = "A new continuous cough"

    public static var confirmTapped = "Confirm button tapped"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            SymptomsReviewViewController(
                symptomsQuestionnaire: InterfaceSymptomsQuestionnaire(
                    riskThreshold: 1.0,
                    symptoms: [
                        SymptomInfo(isConfirmed: false, heading: deniedForFeverish, content: ""),
                        SymptomInfo(isConfirmed: true, heading: confirmedForCough, content: ""),
                    ],
                    cardinal: CardinalSymptomInfo(),
                    noncardinal: CardinalSymptomInfo(),
                    dateSelectionWindow: 14,
                    isSymptomaticSelfIsolationForWalesEnabled: false
                ),
                currentDateProvider: DateProvider(),
                interactor: Interactor(viewController: parent)
            )
        }
    }
}

private class Interactor: SymptomsReviewViewController.Interacting {
    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    var isSymptomaticSelfIsolationForWalesDisabled: Bool = false

    func changeSymptomAnswer(index: Int) {
        viewController?.showAlert(title: "\(index)")
    }

    func confirmSymptoms(riskThreshold: Double, selectedDay: GregorianDay?, hasCheckedNoDate: Bool) -> Result<Void, UIValidationError> {
        viewController?.showAlert(title: SymptomsReviewViewControllerScenario.confirmTapped)
        return .success(())
    }

    var hasError: Bool = true
}
