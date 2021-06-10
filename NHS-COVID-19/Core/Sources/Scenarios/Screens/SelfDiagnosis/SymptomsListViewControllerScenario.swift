//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Domain
import Integration
import Interface
import UIKit

public class SymptomsListViewControllerScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Self-Diagnosis - Symptoms List"
    
    public static let cancelTapped: String = "Cancel button tapped"
    public static let reportTapped: String = "Report button tapped"
    public static let noSymptomsTapped: String = "No symptoms button tapped"
    
    public static let symptom1Value = "unchecked"
    public static let symptom1Heading = "Heading 1 Heading 1 Heading 1"
    public static let symptom1Content = "Content 1 Content 1 Content 1 Content 1 Content 1"
    
    public static let symptom2Value = "checked"
    public static let symptom2Heading = "Heading 2"
    public static let symptom2Content = "Content 2"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return SymptomListViewController(
                symptoms: [
                    SymptomInfo(isConfirmed: false, heading: symptom1Heading, content: symptom1Content),
                    SymptomInfo(isConfirmed: true, heading: symptom2Heading, content: symptom2Content),
                ],
                scrollToSymptomAt: nil,
                interactor: interactor
            )
        }
    }
}

private class Interactor: SymptomListViewController.Interacting {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func didTapCancel() {
        viewController?.showAlert(title: SymptomsListViewControllerScenario.cancelTapped)
    }
    
    func didTapReportButton() -> Result<Void, UIValidationError> {
        viewController?.showAlert(title: SymptomsListViewControllerScenario.reportTapped)
        return .success(())
    }
    
    func didTapNoSymptomsButton() {
        viewController?.showAlert(title: SymptomsListViewControllerScenario.noSymptomsTapped)
    }
}
