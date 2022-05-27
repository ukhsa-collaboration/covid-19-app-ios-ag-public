//
// Copyright © 2022 DHSC. All rights reserved.
//

import Common
import Domain
import Integration
import Interface
import UIKit

public class CheckYourAnswersViewControllerScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Symptoms Checker - Check your Answers"

    public static let changeButtonTapped = "Change button tapped"
    public static let sumbitAnswersTapped = "Submit answers button tapped"
    public static let backButtonTapped = "Back button tapped"
    
    public static let cardinalSymptomsHeading = "Do you have a high temperature?"
    public static let nonCardinalSymptomsHeading = "Do you have any of these symptoms of COVID-19?"
    public static let nonCardinalSymptomsContent = "Shivering or chills"
    public static let nonCardinalSymptomsContent2 = "A new, continuous cough"
    public static let nonCardinalSymptomsContent3 = "A loss or change to your sence of smell or taste"
    
    public static let firstChangeButtonId: String = "firstChangeButtonId"
    public static let secondChangeButtonId: String = "secondChangeButtonId"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return CheckYourAnswersViewController(
                symptomsQuestionnaire: InterfaceSymptomsQuestionnaire(
                    riskThreshold: 0.0,
                    symptoms: [],
                    cardinal: CardinalSymptomInfo(heading: cardinalSymptomsHeading),
                    noncardinal: CardinalSymptomInfo(heading: nonCardinalSymptomsHeading, content: [nonCardinalSymptomsContent, nonCardinalSymptomsContent2, nonCardinalSymptomsContent3]),
                    dateSelectionWindow: 0
                ),
                doYouFeelWell: nil,
                interactor: interactor
            )
        }
    }
}

private class Interactor: CheckYourAnswersViewController.Interacting {
    var firstChangeButtonId: String = CheckYourAnswersViewControllerScenario.firstChangeButtonId
    var secondChangeButtonId: String = CheckYourAnswersViewControllerScenario.secondChangeButtonId
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
  
    func changeYourSymptoms() {
        viewController?.showAlert(title: CheckYourAnswersViewControllerScenario.changeButtonTapped)
    }
    
    func changeHowYouFeel() {
        viewController?.showAlert(title: CheckYourAnswersViewControllerScenario.changeButtonTapped)
    }
    
    func confirmAnswers() {
        viewController?.showAlert(title: CheckYourAnswersViewControllerScenario.sumbitAnswersTapped)
    }
    
    func didTapBackButton() {
        viewController?.showAlert(title: CheckYourAnswersViewControllerScenario.backButtonTapped)
    }
}
