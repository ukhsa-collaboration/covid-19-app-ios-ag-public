//
// Copyright © 2021 DHSC. All rights reserved.
//

import Domain
import Integration
import Interface
import UIKit

public class PositiveSymptomsScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Self-Diagnosis - Positive symptoms"

    public static let getAFreeRapidLateralFlowTestTapped: String = "Get a free rapid lateral flow test kit"
    public static let cancelTapped: String = "Cancel tapped"
    public static let furtherAdviceTapped: String = "Further advice tapped"
    public static let exposureFAQstapped = "Exposure FAQs tapped"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return PositiveSymptomsViewController(interactor: interactor, isolationEndDate: Date(timeIntervalSinceNow: 7 * 86400), currentDateProvider: MockDateProvider())
        }
    }
}

private class Interactor: PositiveSymptomsViewController.Interacting {

    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func didTapGetRapidLateralFlowTest() {
        viewController?.showAlert(title: PositiveSymptomsScreenScenario.getAFreeRapidLateralFlowTestTapped)
    }

    func didTapCancel() {
        viewController?.showAlert(title: PositiveSymptomsScreenScenario.cancelTapped)
    }

    func furtherAdviceLinkTapped() {
        viewController?.showAlert(title: PositiveSymptomsScreenScenario.furtherAdviceTapped)
    }

    func exposureFAQsLinkTapped() {
        viewController?.showAlert(title: PositiveSymptomsScreenScenario.exposureFAQstapped)
    }
}
