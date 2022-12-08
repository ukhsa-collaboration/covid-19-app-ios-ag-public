//
// Copyright © 2022 DHSC. All rights reserved.
//

import Integration
import Interface
import UIKit

public protocol SelfReportingAnswersSubmittedScreenTestScenario: TestScenario {}

extension SelfReportingAnswersSubmittedScreenTestScenario {
    public static var kind: ScenarioKind { .screen }
    public static var primaryButtonTapped: String { "Primary button tapped" }
}

protocol SelfReportingAnswersSubmittedScreenScenario: SelfReportingAnswersSubmittedScreenTestScenario, Scenario {
    typealias State = SelfReportingAnswersSubmittedViewController.State
    static var state: State { get }
}

extension SelfReportingAnswersSubmittedScreenScenario {

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent, primaryButtonAlertText: primaryButtonTapped)
            return SelfReportingAnswersSubmittedViewController(interactor: interactor, state: Self.state)
        }
    }
}

public class AnswersSubmittedSharedKeysReportedResultScreenScenario: SelfReportingAnswersSubmittedScreenScenario {
    static var state = State.shared(reportedResult: true)
    public static var name: String = "Self-Reporting - Answers submitted (shared keys, reported result)"
}

public class AnswersSubmittedSharedKeysNotReportedResultScreenScenario: SelfReportingAnswersSubmittedScreenScenario {
    static var state = State.shared(reportedResult: false)
    public static var name: String = "Self-Reporting - Answers submitted (shared keys, not reported result)"
}

public class AnswersSubmittedNotSharedKeysReportedResultScreenScenario: SelfReportingAnswersSubmittedScreenScenario {
    static var state = State.notShared(reportedResult: true)
    public static var name: String = "Self-Reporting - Answers submitted (not shared keys, reported result)"
}

public class AnswersSubmittedNotSharedKeysNotReportedResultScreenScenario: SelfReportingAnswersSubmittedScreenScenario {
    static var state = State.notShared(reportedResult: false)
    public static var name: String = "Self-Reporting - Answers submitted (not shared keys, not reported result)"
}

private class Interactor: SelfReportingAnswersSubmittedViewController.Interacting {
    var primaryButtonAction: () -> Void

    init(viewController: UIViewController, primaryButtonAlertText: String) {
        primaryButtonAction = { [weak viewController] in
            viewController?.showAlert(title: primaryButtonAlertText)
        }
    }

    func didTapPrimaryButton() {
        primaryButtonAction()
    }
}
