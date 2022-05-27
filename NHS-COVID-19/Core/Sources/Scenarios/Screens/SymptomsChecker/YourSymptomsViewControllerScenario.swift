//
// Copyright © 2022 DHSC. All rights reserved.
//

import Common
import Domain
import Integration
import Interface
import UIKit

public class YourSymptomsViewControllerScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Symptoms Checker - Your Symptoms"
    
    public static let cancelTapped: String = "Back button tapped"
    
    public static let noNoOptionAlertTitle = "Options selected: No, No."
    public static let noYesOptionAlertTitle = "Options selected: No, Yes."
    public static let yesNoOptionAlertTitle = "Options selected: Yes, No."
    public static let yesYesOptionAlertTitle = "Options selected: Yes, Yes."
    
    public static let cardinalSymptomsHeading = "Do you have a high temperature?"
    public static let nonCardinalSymptomsHeading = "Do you have any of these symptoms of COVID-19?"
    public static let nonCardinalSymptomsContent = "Shivering or chills"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return YourSymptomsViewController(
                symptomsQuestionnaire: InterfaceSymptomsQuestionnaire(
                    riskThreshold: 0.0,
                    symptoms: [],
                    cardinal: CardinalSymptomInfo(heading: cardinalSymptomsHeading),
                    noncardinal: CardinalSymptomInfo(heading: nonCardinalSymptomsHeading, content: [nonCardinalSymptomsContent]),
                    dateSelectionWindow: 0
                ),
                interactor: interactor
            )
        }
    }
}

private class Interactor: YourSymptomsViewController.Interacting {
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func didTapCancel() {
        viewController?.showAlert(title: YourSymptomsViewControllerScenario.cancelTapped)
    }
    
    func didTapReportButton(hasNonCardinalSymptoms: Bool, hasCardinalSymptoms: Bool) {
        if !hasNonCardinalSymptoms && !hasCardinalSymptoms {
            viewController?.showAlert(title: YourSymptomsViewControllerScenario.noNoOptionAlertTitle)
        } else if !hasNonCardinalSymptoms && hasCardinalSymptoms {
            viewController?.showAlert(title: YourSymptomsViewControllerScenario.noYesOptionAlertTitle)
        } else if hasNonCardinalSymptoms && !hasCardinalSymptoms {
            viewController?.showAlert(title: YourSymptomsViewControllerScenario.yesNoOptionAlertTitle)
        } else if hasNonCardinalSymptoms && hasCardinalSymptoms {
            viewController?.showAlert(title: YourSymptomsViewControllerScenario.yesYesOptionAlertTitle)
        }
    }
}
