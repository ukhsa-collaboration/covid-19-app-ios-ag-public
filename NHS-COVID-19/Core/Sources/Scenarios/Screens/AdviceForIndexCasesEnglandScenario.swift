//
// Copyright © 2022 DHSC. All rights reserved.
//

import Integration
import Interface
import UIKit

public class AdviceForIndexCasesEnglandScenario: Scenario {
    public static var name = "Advice For Index Cases in England"
    public static var kind: ScenarioKind = .screen
    public static let didTapCommonQuestionsLink = "Did Tap Common Questions Link"
    public static let ditTapNHSOnline = "Did tap NHS online"
    public static let didTapContinueButton = "Did Tap Continue Button"
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return AdviceForIndexCasesEnglandViewController(interactor: interactor)
        }
    }
}

private struct Interactor: AdviceForIndexCasesEnglandViewController.Interacting {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    public func didTapCommonQuestions() {
        viewController?.showAlert(title: AdviceForIndexCasesEnglandScenario.didTapCommonQuestionsLink)
    }
    
    public func didTapNHSOnline() {
        viewController?.showAlert(title: AdviceForIndexCasesEnglandScenario.ditTapNHSOnline)
    }
    
    public func didTapContinue() {
        viewController?.showAlert(title: AdviceForIndexCasesEnglandScenario.didTapContinueButton)
    }
    
}
