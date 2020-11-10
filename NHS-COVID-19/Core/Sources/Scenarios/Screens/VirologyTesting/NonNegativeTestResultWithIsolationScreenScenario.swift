//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Domain
import Integration
import Interface
import UIKit

protocol NonNegativeTestResultWithIsolationScreenScenario: Scenario {
    typealias TestResultType = NonNegativeTestResultWithIsolationViewController.TestResultType
    static var testResultType: TestResultType { get }
}

extension NonNegativeTestResultWithIsolationScreenScenario {
    public static var kind: ScenarioKind { .screen }
    public static var onlineServicesLinkTapped: String { "Online services link tapped" }
    public static var exposureFAQLinkTapped: String { "Exposure FAQ link tapped" }
    public static var primaryButtonTapped: String { "Primary button tapped" }
    public static var noThanksLinkTapped: String { "No thanks link tapped" }
    public static var daysToIsolate: Int { 7 }
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent, buttonAlertText: primaryButtonTapped, cancelTappedAlertText: nil, onlineServicesTappedText: Self.onlineServicesLinkTapped, exposureFAQTappedText: Self.exposureFAQLinkTapped)
            return NonNegativeTestResultWithIsolationViewController(interactor: interactor, isolationEndDate: Date(timeIntervalSinceNow: Double(daysToIsolate) * 86400), testResultType: Self.testResultType)
        }
    }
}

public class PositiveTestResultContinueIsolationScreenScenario: NonNegativeTestResultWithIsolationScreenScenario {
    static var testResultType = TestResultType.positive(.continue)
    public static var name: String = "Virology Testing - Positive Result (Continue Isolation)"
}

public class PositiveTestResultStartIsolationScreenScenario: NonNegativeTestResultWithIsolationScreenScenario {
    static var testResultType = TestResultType.positive(.start)
    public static var name: String = "Virology Testing - Positive Result (Start Isolation)"
}

public class VoidTestResultWithIsolationScreenScenario: NonNegativeTestResultWithIsolationScreenScenario {
    static var testResultType = TestResultType.void
    public static var name: String = "Virology Testing - Void Result"
}

private class Interactor: NonNegativeTestResultWithIsolationViewController.Interacting {
    var didTapOnlineServicesLink: () -> Void
    var didTapExposureFAQLink: () -> Void
    var didTapPrimaryButton: () -> Void
    var didTapCancel: (() -> Void)?
    
    init(viewController: UIViewController, buttonAlertText: String, cancelTappedAlertText: String?, onlineServicesTappedText: String, exposureFAQTappedText: String) {
        didTapOnlineServicesLink = { [weak viewController] in
            viewController?.showAlert(title: onlineServicesTappedText)
        }
        
        didTapExposureFAQLink = { [weak viewController] in
            viewController?.showAlert(title: exposureFAQTappedText)
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
