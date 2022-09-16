import Integration
import Interface
import UIKit

public class AdviceForIndexCasesEnglandAlreadyIsolatingScenario: Scenario {
    public static var name = "Advice For Index Cases in England Already Isoalating"
    public static var kind: ScenarioKind = .screen
    public static let didTapCommonQuestionsLink = "Did Tap Common Questions Link"
    public static let ditTapNHSOnline = "Did tap NHS online"
    public static let didTapContinueButton = "Did Tap Continue Button"
    public static var daysToIsolate: Int { 6 }

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return AdviceForIndexCasesEnglandAlreadyIsolatingViewController(
                interactor: interactor,
                isolationEndDate: Date(timeIntervalSinceNow: Double(daysToIsolate) * 86400),
                currentDateProvider: MockDateProvider()
            )
        }
    }
}

private struct Interactor: AdviceForIndexCasesEnglandAlreadyIsolatingViewController.Interacting {

    private weak var viewController: UIViewController?

    init(viewController: UIViewController) {
        self.viewController = viewController
    }

    public func didTapCommonQuestions() {
        viewController?.showAlert(title: AdviceForIndexCasesEnglandAlreadyIsolatingScenario.didTapCommonQuestionsLink)
    }

    public func didTapNHSOnline() {
        viewController?.showAlert(title: AdviceForIndexCasesEnglandAlreadyIsolatingScenario.ditTapNHSOnline)
    }

    public func didTapContinue() {
        viewController?.showAlert(title: AdviceForIndexCasesEnglandAlreadyIsolatingScenario.didTapContinueButton)
    }

}

