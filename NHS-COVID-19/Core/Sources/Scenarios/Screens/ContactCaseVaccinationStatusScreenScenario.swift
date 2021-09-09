//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Integration
import Interface
import UIKit

public class ContactCaseVaccinationStatusScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Contact Case Exposure - Vaccination"
    
    public static let confirmFullyVaccinatedTapped = "Confirm that is fully vaccinated tapped"
    public static let confirmNotFullyVaccinatedTapped = "Confirm that is not fully vaccinated tapped"
    public static let linkTapped = "Link tapped"
    public static let vaccineThresholdDate = Date(timeIntervalSinceNow: -15 * 86400)
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return ContactCaseVaccinationStatusViewController(
                interactor: interactor,
                vaccineThresholdDate: vaccineThresholdDate,
                isIndexCase: false
            )
        }
    }
}

private class Interactor: ContactCaseVaccinationStatusViewController.Interacting {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func didTapEditPostcode() {
        viewController?.showAlert(title: MyAreaScreenScenario.editTappeed)
    }
    
    func didTapAboutApprovedVaccinesLink() {
        viewController?.showAlert(title: ContactCaseVaccinationStatusScreenScenario.linkTapped)
    }
    
    func didAnswerQuestion(fullyVaccinated: Bool?, lastDose: Bool?, clinicalTrial: Bool?, medicallyExempt: Bool?) -> [ContactCaseVaccinationStatusQuestion] {
        if let fullyVaccinated = fullyVaccinated {
            if fullyVaccinated {
                return [.fullyVaccinated, .lastDose]
            } else {
                return [.fullyVaccinated]
            }
        } else {
            return [.fullyVaccinated]
        }
    }
    
    func didTapConfirm(fullyVaccinated: Bool?, lastDose: Bool?, clinicalTrial: Bool?, medicallyExempt: Bool?) -> Result<Void, ContactCaseVaccinationStatusNotEnoughAnswersError> {
        if let fullyVaccinated = fullyVaccinated {
            if let lastDose = lastDose {
                if fullyVaccinated, lastDose {
                    viewController?.showAlert(title: ContactCaseVaccinationStatusScreenScenario.confirmFullyVaccinatedTapped)
                } else {
                    viewController?.showAlert(title: ContactCaseVaccinationStatusScreenScenario.confirmNotFullyVaccinatedTapped)
                }
                return Result.success(())
            } else {
                if fullyVaccinated {
                    return Result.failure(ContactCaseVaccinationStatusNotEnoughAnswersError())
                } else {
                    viewController?.showAlert(title: ContactCaseVaccinationStatusScreenScenario.confirmNotFullyVaccinatedTapped)
                    return Result.success(())
                }
            }
        } else {
            return Result.failure(ContactCaseVaccinationStatusNotEnoughAnswersError())
        }
    }
    
}
