//
// Copyright © 2022 DHSC. All rights reserved.
//

import Common
import Domain
import Integration
import Interface
import UIKit

public class SelfReportingTestDateScreenScenario: Scenario {
    public static let name = "Self-Reporting - Test date"
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
                state: .testDate(testKitType: .rapidSelfReported)
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
            viewController.showAlert(title: SelfReportingTestDateScreenScenario.doNotRememberChecked)
        } else {
            viewController.showAlert(title: SelfReportingTestDateScreenScenario.primaryButtonTapped)
        }
    }

    func didTapBackButton() {
        viewController.showAlert(title: SelfReportingTestDateScreenScenario.backButtonTapped)
    }
}
