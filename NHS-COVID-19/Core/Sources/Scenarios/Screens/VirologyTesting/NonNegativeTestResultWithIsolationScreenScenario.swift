//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Domain
import Integration
import Interface
import UIKit

// Below is probably not the best pattern, but is a small improvement over the previous pattern that lets us avoid using
// `@testable` in the UI tests.

// A public protocol extending `TestScenario`; used just to provide some static methods.
public protocol NonNegativeTestResultWithIsolationScreenTestScenario: TestScenario {}

extension NonNegativeTestResultWithIsolationScreenTestScenario {
    public static var kind: ScenarioKind { .screen }
    public static var onlineServicesLinkTapped: String { "Online services link tapped" }
    public static var exposureFAQLinkTapped: String { "Exposure FAQ link tapped" }
    public static var nhsGuidanceLinkTapped: String { "NHS guidance link tapped" }
    public static var primaryButtonTapped: String { "Primary button tapped" }
    public static var noThanksLinkTapped: String { "No thanks link tapped" }
    public static var daysToIsolate: Int { 7 }
}

// A private protocol extending both the public protocol above and `Scenario`.
protocol NonNegativeTestResultWithIsolationScreenScenario: NonNegativeTestResultWithIsolationScreenTestScenario, Scenario {
    typealias TestResultType = NonNegativeTestResultWithIsolationViewController.TestResultType
    static var testResultType: TestResultType { get }
}

extension NonNegativeTestResultWithIsolationScreenScenario {

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent, buttonAlertText: primaryButtonTapped, cancelTappedAlertText: nil, onlineServicesTappedText: Self.onlineServicesLinkTapped, exposureFAQTappedText: Self.exposureFAQLinkTapped, nhsGuidanceTappedText: Self.nhsGuidanceLinkTapped)
            return NonNegativeTestResultWithIsolationViewController(interactor: interactor, isolationEndDate: Date(timeIntervalSinceNow: Double(daysToIsolate) * 86400), testResultType: Self.testResultType, currentDateProvider: MockDateProvider())
        }
    }
}

public class PositiveTestResultContinueIsolationScreenScenario: NonNegativeTestResultWithIsolationScreenScenario {
    static var testResultType = TestResultType.positive(isolation: .continue, requiresConfirmatoryTest: false)
    public static var name: String = "Virology Testing - Positive Result (Continue Isolation)"
}

public class PositiveTestResultStartIsolationScreenScenario: NonNegativeTestResultWithIsolationScreenScenario {
    static var testResultType = TestResultType.positive(isolation: .start, requiresConfirmatoryTest: false)
    public static var name: String = "Virology Testing - Positive Result (Start Isolation)"
}

public class PositiveTestResultContinueIsolationAfterConfirmedScreenScenario: NonNegativeTestResultWithIsolationScreenScenario {
    static var testResultType = TestResultType.positiveButAlreadyConfirmedPositive
    public static var name: String = "Virology Testing - Positive Result After Already Confirmed Positive (Continue Isolation)"
}

public class VoidTestResultWithIsolationScreenScenario: NonNegativeTestResultWithIsolationScreenScenario {
    static var testResultType = TestResultType.void
    public static var name: String = "Virology Testing - Void Result"
}

private class Interactor: NonNegativeTestResultWithIsolationViewController.Interacting {
    var didTapOnlineServicesLink: () -> Void
    var didTapExposureFAQLink: () -> Void
    var didTapNHSGuidanceLink: () -> Void
    var didTapPrimaryButton: () -> Void
    var didTapCancel: (() -> Void)?

    init(viewController: UIViewController, buttonAlertText: String, cancelTappedAlertText: String?, onlineServicesTappedText: String, exposureFAQTappedText: String, nhsGuidanceTappedText: String) {
        didTapOnlineServicesLink = { [weak viewController] in
            viewController?.showAlert(title: onlineServicesTappedText)
        }

        didTapExposureFAQLink = { [weak viewController] in
            viewController?.showAlert(title: exposureFAQTappedText)
        }

        didTapNHSGuidanceLink = { [weak viewController] in
            viewController?.showAlert(title: nhsGuidanceTappedText)
        }

        didTapPrimaryButton = { [weak viewController] in
            viewController?.showAlert(title: buttonAlertText)
        }

        didTapCancel = cancelTappedAlertText.map { cancelTappedAlertText in
            { [weak viewController] in
                viewController?.showAlert(title: cancelTappedAlertText)
            }
        }
    }
}
