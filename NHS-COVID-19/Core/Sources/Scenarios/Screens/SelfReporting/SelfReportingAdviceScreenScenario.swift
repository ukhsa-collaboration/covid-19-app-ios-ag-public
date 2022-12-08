//
// Copyright © 2022 DHSC. All rights reserved.
//

import Combine
import Domain
import Integration
import Interface
import UIKit

public protocol SelfReportingAdviceScreenTestScenario: TestScenario {}

extension SelfReportingAdviceScreenTestScenario {
    public static var kind: ScenarioKind { .screen }
    public static var readMoreLinkTapped: String { "Read more tapped" }
    public static var reportResultLinkTapped: String { "Report your result tapped" }
    public static var backToHomeButtonTapped: String { "Back to home tapped" }
}

protocol SelfReportingAdviceScreenScenario: SelfReportingAdviceScreenTestScenario, Scenario {
    typealias State = SelfReportingAdviceViewController.State
    static var state: State { get }
}

extension SelfReportingAdviceScreenScenario {
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(
                viewController: parent,
                readMoreLinkTapped: readMoreLinkTapped,
                reportResultLinkTapped: reportResultLinkTapped,
                backToHomeButtonTapped: backToHomeButtonTapped
            )
            return SelfReportingAdviceViewController(interactor: interactor, state: Self.state)
        }
    }
}

public class AdviceReportedResultScreenScenario: SelfReportingAdviceScreenScenario {
    static var state = State.reportedResult(isolationDuration: 6)
    public static var name: String = "Self-Reporting - Advice (reported result)"
}

public class AdviceNotReportedResultScreenScenario: SelfReportingAdviceScreenScenario {
    static var state = State.notReportedResult(isolationDuration: 6, endDate: Calendar.current.date(byAdding: .day, value: 5, to: Date())!)
    public static var name: String = "Self-Reporting - Advice (not reported result)"
}

public class AdviceReportedResultOutOfIsolationScreenScenario: SelfReportingAdviceScreenScenario {
    static var state = State.reportedResultOutOfIsolation
    public static var name: String = "Self-Reporting - Advice (reported result, out of isolation)"
}

public class AdviceNotReportedResultOutOfIsolationScreenScenario: SelfReportingAdviceScreenScenario {
    static var state = State.notReportedResultOutOfIsolation
    public static var name: String = "Self-Reporting - Advice (not reported result, out of isolation)"
}

private class Interactor: SelfReportingAdviceViewController.Interacting {
    var readMoreLinkTapped: () -> Void
    var reportResultLinkTapped: () -> Void
    var backToHomeButtonTapped: () -> Void

    init(viewController: UIViewController, readMoreLinkTapped: String, reportResultLinkTapped: String, backToHomeButtonTapped: String) {
        self.readMoreLinkTapped = { [weak viewController] in
            viewController?.showAlert(title: readMoreLinkTapped)
        }

        self.reportResultLinkTapped = { [weak viewController] in
            viewController?.showAlert(title: reportResultLinkTapped)
        }

        self.backToHomeButtonTapped = { [weak viewController] in
            viewController?.showAlert(title: backToHomeButtonTapped)
        }
    }

    func didTapReadMoreLink() {
        readMoreLinkTapped()
    }

    func didTapReportResult() {
        reportResultLinkTapped()
    }

    func didTapBackToHome() {
        backToHomeButtonTapped()
    }
}
