//
// Copyright © 2022 DHSC. All rights reserved.
//

import Combine
import Common
import Domain
import Integration
import Interface
import UIKit

public protocol SymptomaticCaseSummaryScreenScenario {
    static var adviseForSymptomaticCase: SymptomaticSummaryResult { get }
}

extension SymptomaticCaseSummaryScreenScenario {
    public static var kind: ScenarioKind { .screen }
    public static var didTapReturnHome: String { String("Back To Home") }
    public static var didTapOnlineServicesLink: String { String("Online services link tapped") }
    public static var didTapSymptomaticCase: String { String("Advice link tapped") }
    public static var didTapCancel: String { String("Back button tapped") }
    public static var didTapSymptomCheckerNormalActivities: String { String("Online services link tapped") }
    public static var nhs111Online: String { String("Online services link tapped") }
        
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return SymptomaticCaseSummaryViewController(interactor: interactor, adviseForSymptomaticCase: adviseForSymptomaticCase)
        }
    }
}

public class SymptomaticCaseSummaryTryStayHomeScreenScenario: SymptomaticCaseSummaryScreenScenario, Scenario {
    public static var adviseForSymptomaticCase = SymptomaticSummaryResult.tryStayHome
    public static var name: String = "Summary Page for Symptom Checker (Try stay home)"
    public static var kind = ScenarioKind.screen
}

public class SymptomaticCaseSummaryContinueWithNormalActivitiesScreenScenario: SymptomaticCaseSummaryScreenScenario, Scenario {
    public static var adviseForSymptomaticCase = SymptomaticSummaryResult.continueWithNormalActivities
    public static var name: String = "Summary Page for Symptom Checker (Continue with normal activities)"
    public static var kind = ScenarioKind.screen
}

private class Interactor: SymptomaticCaseSummaryViewController.Interacting {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func didTapSymptomCheckerNormalActivities() {
        viewController?.showAlert(title: SymptomaticCaseSummaryContinueWithNormalActivitiesScreenScenario.didTapSymptomCheckerNormalActivities)
    }
    
    func didTapCancel() {
        viewController?.showAlert(title: SymptomaticCaseSummaryTryStayHomeScreenScenario.didTapCancel)
    }
    
    func didTapOnlineServicesLink() {
        viewController?.showAlert(title: SymptomaticCaseSummaryTryStayHomeScreenScenario.didTapOnlineServicesLink)
    }
    
    func didTapSymptomaticCase() {
        viewController?.showAlert(title: SymptomaticCaseSummaryTryStayHomeScreenScenario.didTapSymptomaticCase)
    }
    
    func didTapReturnHome() {
        viewController?.showAlert(title: SymptomaticCaseSummaryTryStayHomeScreenScenario.didTapReturnHome)
    }
}
