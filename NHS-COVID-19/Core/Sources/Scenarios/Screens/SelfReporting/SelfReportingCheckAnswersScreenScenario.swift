//
// Copyright © 2022 DHSC. All rights reserved.
//

import Common
import Domain
import Integration
import Interface
import UIKit

public class SelfReportingCheckAnswersScreenScenario: Scenario {
    public static let name = "Self-Reporting - Check your answers"
    public static let kind = ScenarioKind.screen
    public static let primaryButtonTapped = "'Submit and continue' tapped"
    public static let backButtonTapped = "Back button tapped"
    public static let didTapChangeTestKitType = "Change Test type"
    public static let didTapChangeTestSupplier = "Change How you got your test"
    public static let didTapChangeTestDay = "Change Test date"
    public static let didTapChangeSymptoms = "Change Symptoms"
    public static let didTapChangeSymptomsDay = "Change Symptoms date"
    public static let didTapChangeReportedResult = "Change Whether you've reported"

    static var appController: AppController {
        let currentDateProvider = DateProvider()
        return NavigationAppController { (parent: UINavigationController) in
            SelfReportingCheckAnswersViewController(
                interactor: Interactor(viewController: parent),
                info: SelfReportingInfo(
                    testResult: .positive,
                    testKitType: .rapidSelfReported,
                    nhsTest: true,
                    testDay: SelectedDay(day: currentDateProvider.currentGregorianDay(timeZone: .current), doNotRemember: true),
                    symptoms: true,
                    symptomsDay: SelectedDay(day: currentDateProvider.currentGregorianDay(timeZone: .current), doNotRemember: true),
                    reportedResult: true
                )
            )
        }
    }
}

private struct Interactor: SelfReportingCheckAnswersViewController.Interacting {
    private let viewController: UIViewController

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func didTapPrimaryButton() {
        viewController.showAlert(title: SelfReportingCheckAnswersScreenScenario.primaryButtonTapped)
    }

    func didTapBackButton() {
        viewController.showAlert(title: SelfReportingCheckAnswersScreenScenario.backButtonTapped)
    }

    func didTapChangeTestKitType() {
        viewController.showAlert(title: SelfReportingCheckAnswersScreenScenario.didTapChangeTestKitType)
    }

    func didTapChangeTestSupplier() {
        viewController.showAlert(title: SelfReportingCheckAnswersScreenScenario.didTapChangeTestSupplier)
    }

    func didTapChangeTestDay() {
        viewController.showAlert(title: SelfReportingCheckAnswersScreenScenario.didTapChangeTestDay)
    }

    func didTapChangeSymptoms() {
        viewController.showAlert(title: SelfReportingCheckAnswersScreenScenario.didTapChangeSymptoms)
    }

    func didTapChangeSymptomsDay() {
        viewController.showAlert(title: SelfReportingCheckAnswersScreenScenario.didTapChangeSymptomsDay)
    }

    func didTapChangeReportedResult() {
        viewController.showAlert(title: SelfReportingCheckAnswersScreenScenario.didTapChangeReportedResult)
    }
}
