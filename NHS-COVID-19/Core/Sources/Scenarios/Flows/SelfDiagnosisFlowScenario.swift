//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Domain
import Integration
import Interface
import UIKit

public class SelfDiagnosisFlowScenario: Scenario {
    
    public static var name = "Self-Diagnosis"
    public static var kind = ScenarioKind.flow
    
    public static var symptomCardHeading = "Heading"
    public static var symptomCardContent = "Content"
    
    static var appController: AppController {
        Controller()
    }
    
    private class Controller: AppController {
        
        let rootViewController = UIViewController()
        
        init() {
            let flow = SelfDiagnosisFlowViewController(DiagnosisInteractor(viewController: rootViewController), initialIsolationState: .notIsolating)
            rootViewController.addFilling(flow)
        }
    }
}

private struct DiagnosisInteractor: SelfDiagnosisFlowViewController.Interacting {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func fetchQuestionnaire() -> AnyPublisher<InterfaceSymptomsQuestionnaire, Error> {
        Future<InterfaceSymptomsQuestionnaire, Error>({ promise in
            promise(.success(
                InterfaceSymptomsQuestionnaire(
                    symptoms: [SymptomInfo(
                        isConfirmed: false,
                        heading: SelfDiagnosisFlowScenario.symptomCardHeading,
                        content: SelfDiagnosisFlowScenario.symptomCardContent
                    )],
                    dateSelectionWindow: 14
                )
            ))
            // promise(.failure(URLError(.badServerResponse)))
        }).eraseToAnyPublisher()
    }
    
    func evaluateSymptoms(symptoms: [SymptomInfo], onsetDay: GregorianDay?) -> Date? {
        Date(timeIntervalSinceNow: 7 * 86400)
    }
    
    func openTestkitOrder() {
        viewController?.showAlert(title: "Book a test tapped")
    }
    
    func furtherAdviceLinkTapped() {
        viewController?.showAlert(title: "Further advice tapped")
    }
    
    func nhs111LinkTapped() {
        viewController?.showAlert(title: "NHS 111 online tapped")
    }
}

extension DiagnosisInteractor: BookATestInfoViewControllerInteracting {
    func didTapTestingPrivacyNotice() {
        viewController?.showAlert(title: "Did tap testing privacy notice")
    }
    
    func didTapAppPrivacyNotice() {
        viewController?.showAlert(title: "Did tap app privacy notice")
    }
    
    func didTapBookATestForSomeoneElse() {
        viewController?.showAlert(title: "Did tap book a test for someone else")
    }
    
    func didTapBookATest() {
        viewController?.showAlert(title: "Did tap book a test")
    }
    
}
