//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Domain
import Integration
import Interface
import UIKit

public class TestSymptomsReviewScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Virology Testing - Symptoms Review"

    public static var confirmTapped = "Confirm button tapped"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            TestSymptomsReviewViewController(
                testEndDay: DateProvider().currentGregorianDay(timeZone: .utc),
                dateSelectionWindow: 6,
                interactor: Interactor(viewController: parent)
            )
        }
    }
}

private class Interactor: TestSymptomsReviewViewController.Interacting {
    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func confirmSymptomsDate(selectedDay: GregorianDay?, hasCheckedNoDate: Bool) -> Result<Void, TestSymptomsReviewUIError> {
        if selectedDay == nil, !hasCheckedNoDate {
            return .failure(.neitherDateNorNoDateCheckSet)
        } else {
            viewController?.showAlert(title: SymptomsReviewViewControllerScenario.confirmTapped)
            return .success(())
        }
    }
}
