//
// Copyright © 2021 DHSC. All rights reserved.
//

import Integration
import Interface
import UIKit

public class ContactCaseSummaryScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Contact Case Exposure -  Summary"
    public static let checkYourAnswersTitle = "Check your answers"
    public static let overAgeLimit = true
    public static let birthThresholdDate = Date(timeIntervalSinceNow: -183 * 86400)
    public static let vaccineThresholdDate = Date(timeIntervalSinceNow: -15 * 86400)
    
    public static let changeAgeAnswerButtonTapped = "Change age button tapped"
    public static let changeVaccinationStatusAnswerButtonTapped = "Vaccination status button tapped"
    public static let primaryButtonTappd = "Submit answers button tapped"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            typealias QuestionAndAnswer = ContactCaseSummaryViewController.QuestionAndAnswer
            
            return ContactCaseSummaryViewController(
                interactor: interactor,
                overAgeLimit: overAgeLimit,
                vaccinationStatusQuestionsAndAnswers: [
                    ContactCaseVaccinationStatusQuestionAndAnswer(
                        question: .fullyVaccinated,
                        answer: true
                    ),
                    ContactCaseVaccinationStatusQuestionAndAnswer(
                        question: .lastDose,
                        answer: true
                    ),
                ],
                birthThresholdDate: birthThresholdDate,
                vaccineThresholdDate: vaccineThresholdDate
            )
        }
    }
}

private class Interactor: ContactCaseSummaryViewController.Interacting {
    
    private weak var viewController: UIViewController?
    
    func didTapChangeAgeButton() {
        viewController?.showAlert(title: ContactCaseSummaryScreenScenario.changeAgeAnswerButtonTapped)
    }
    
    func didTapChangeVaccinationStatusButton() {
        viewController?.showAlert(title: ContactCaseSummaryScreenScenario.changeVaccinationStatusAnswerButtonTapped)
    }
    
    func didTapSubmitAnswersButton(overAgeLimit: Bool, vaccinationStatusAnswers: ContactCaseVaccinationStatusAnswers) {
        viewController?.showAlert(title: ContactCaseSummaryScreenScenario.primaryButtonTappd)
    }
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
}
