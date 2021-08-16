//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import Integration
import Interface
import UIKit

public class NewNoSymptomsViewControllerScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name = "Self Diagnosis - (New Design) No Symptoms"
    public static let returnHomeTapped: String = "Return home button tapped"
    public static let nhs111LinkTapped: String = "NHS 111 link tapped"
    public static let bookAPCRTestTapped: String = "Book a free PCR test link tapped"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return NewNoSymptomsViewController(interactor: interactor)
        }
    }
}

private class Interactor: NewNoSymptomsViewController.Interacting {
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func didTapReturnHome() {
        viewController?.showAlert(title: NewNoSymptomsViewControllerScenario.returnHomeTapped)
    }
    
    func didTapNHSGuidanceLink() {
        viewController?.showAlert(title: NewNoSymptomsViewControllerScenario.nhs111LinkTapped)
    }
    
    func didTapBookAPCRTestLink() {
        viewController?.showAlert(title: NewNoSymptomsViewControllerScenario.bookAPCRTestTapped)
    }
}
