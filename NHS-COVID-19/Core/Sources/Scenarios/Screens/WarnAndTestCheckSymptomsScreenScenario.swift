//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Domain
import Integration
import Interface
import UIKit

public class WarnAndTestCheckSymptomsScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Warn and Test Check Symptoms"

    public static let submitButtonTapped: String = "Submit button tapped"
    public static let cancelButtonTapped: String = "Cancel button tapped"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return TestCheckSymptomsViewController.viewController(for: .warnAndBookATest, interactor: interactor)
        }
    }
}

private class Interactor: TestCheckSymptomsViewController.Interacting {
    var didTapYes: () -> Void
    var didTapNo: () -> Void

    init(viewController: UIViewController) {
        didTapYes = { [weak viewController] in
            viewController?.showAlert(title: WarnAndTestCheckSymptomsScreenScenario.submitButtonTapped)
        }

        didTapNo = { [weak viewController] in
            viewController?.showAlert(title: WarnAndTestCheckSymptomsScreenScenario.cancelButtonTapped)
        }
    }
}
