//
// Copyright © 2022 DHSC. All rights reserved.
//

import Common
import Domain
import Integration
import Interface
import UIKit

public class SelfReportingSymptomsDateScreenScenario: Scenario {
    public static let name = "Self-Reporting - Symptoms date"
    public static let kind = ScenarioKind.screen
    public static let doNotRememberChecked = "Continue button tapped, i do not remember the date"
    public static let primaryButtonTapped = "Continue button tapped, day selected"
    public static let backButtonTapped = "Back button tapped"

    static var appController: AppController {
        let currentDateProvider = DateProvider()
        return NavigationAppController { (parent: UINavigationController) in
            SelfReportingSelectDateViewController(
                interactor: Interactor(viewController: parent),
                selectedDay: nil,
                dateSelectionWindow: 6,
                lastSelectionDate: currentDateProvider.currentGregorianDay(timeZone: .current),
                state: .symptomsDate
            )
        }
    }
}

private struct Interactor: SelfReportingSelectDateViewController.Interacting {

    private let viewController: UIViewController

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func didTapPrimaryButton(selectedDay: SelectedDay) {
        if selectedDay.doNotRemember {
            viewController.showAlert(title: SelfReportingSymptomsDateScreenScenario.doNotRememberChecked)
        } else {
            viewController.showAlert(title: SelfReportingSymptomsDateScreenScenario.primaryButtonTapped)
        }
    }

    func didTapBackButton() {
        viewController.showAlert(title: SelfReportingSymptomsDateScreenScenario.backButtonTapped)
    }
}
