//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Domain
import Integration
import Interface
import UIKit

public class TestCheckSymptomsScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Virology Testing - Check Symptoms"
    
    public static let yesTapped: String = "Yes button tapped"
    public static let noTapped: String = "No button tapped"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return TestCheckSymptomsViewController.viewController(for: .enterTestResult, interactor: interactor)
        }
    }
}

private class Interactor: TestCheckSymptomsViewController.Interacting {
    var didTapYes: () -> Void
    var didTapNo: () -> Void
    
    init(viewController: UIViewController) {
        didTapYes = { [weak viewController] in
            viewController?.showAlert(title: TestCheckSymptomsScreenScenario.yesTapped)
        }
        
        didTapNo = { [weak viewController] in
            viewController?.showAlert(title: TestCheckSymptomsScreenScenario.noTapped)
        }
    }
}
