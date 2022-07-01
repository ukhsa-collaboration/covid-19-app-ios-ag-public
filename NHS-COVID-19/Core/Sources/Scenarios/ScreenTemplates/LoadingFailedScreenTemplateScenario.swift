//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

import Integration
import Interface
import UIKit

public class LoadingFailedScreenTemplateScenario: Scenario {
    public static var kind = ScenarioKind.screenTemplate
    public static var name: String = "Loading failed screen"

    public static let retryTapped: String = "Retry button tapped"
    public static let cancelTapped: String = "Cancel button tapped"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return LoadingErrorViewController(interacting: interactor, title: "Loading failed title")
        }
    }
}

private class Interactor: LoadingErrorViewController.Interacting {

    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    func didTapRetry() {
        viewController?.showAlert(title: LoadingFailedScreenTemplateScenario.retryTapped)
    }

    func didTapCancel() {
        viewController?.showAlert(title: LoadingFailedScreenTemplateScenario.cancelTapped)
    }
}
