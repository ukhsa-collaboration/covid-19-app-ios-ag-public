//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import UIKit

public class RiskLevelLowScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Risk Level Low"
    
    public static let linkButtonTaped = "Link to website taped"
    public static let cancelTaped = "Cancel taped"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            let viewModel = RiskLevelInfoViewModel(postcode: "SW12", riskLevel: .low)
            return RiskLevelInfoViewController(viewModel: viewModel, interactor: interactor)
        }
    }
}

public class RiskLevelMediumScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Risk Level Medium"
    
    public static let linkButtonTaped = "Link to website taped"
    public static let cancelTaped = "Cancel taped"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            let viewModel = RiskLevelInfoViewModel(postcode: "SW12", riskLevel: .medium)
            return RiskLevelInfoViewController(viewModel: viewModel, interactor: interactor)
        }
    }
}

public class RiskLevelHighScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Risk Level High"
    
    public static let linkButtonTaped = "Link to website taped"
    public static let cancelTaped = "Cancel taped"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            let viewModel = RiskLevelInfoViewModel(postcode: "SW12", riskLevel: .high)
            return RiskLevelInfoViewController(viewModel: viewModel, interactor: interactor)
        }
    }
}

private class Interactor: RiskLevelInfoViewController.Interacting {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func didTapWebsiteLink() {
        viewController?.showAlert(title: RiskLevelLowScreenScenario.linkButtonTaped)
    }
    
    func didTapCancel() {
        viewController?.showAlert(title: RiskLevelLowScreenScenario.cancelTaped)
    }
    
}
