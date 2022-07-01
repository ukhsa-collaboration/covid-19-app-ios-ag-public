//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Integration
import Interface
import UIKit

public class LinkTestResultScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Link test result - code input"

    public enum TestCodes: String {
        case invalid = "ABC"
        case valid = "abcd1234"
        case delayed = "DE"
    }

    public static let continueConfirmationAlertTitle = "Entered test code"
    public static let cancelAlertTitle = "Did tap cancel"
    public static let tapReportLFDOnGovUKMessage = "'Report result on GOV.UK' tapped"
    public static let openAppStoreTitle = "Open app store"
    public static let invalidCodeError = "[MOCK] Invalid code"

    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            LinkTestResultViewController(interactor: LinkTestResultViewControllerInteractor(viewController: parent))
        }
    }

    private struct LinkTestResultViewControllerInteractor: LinkTestResultViewController.Interacting {
        var viewController: UIViewController

        func cancel() {}

        func submit(testCode: String) -> AnyPublisher<Void, LinkTestValidationError> {

            switch testCode.uppercased() {
            case LinkTestResultScreenScenario.TestCodes.invalid.rawValue:
                return Result.failure(LinkTestValidationError.testCode(DisplayableError(testValue: LinkTestResultScreenScenario.invalidCodeError))).publisher.eraseToAnyPublisher()
            case LinkTestResultScreenScenario.TestCodes.delayed.rawValue:
                viewController.showAlert(title: LinkTestResultScreenScenario.continueConfirmationAlertTitle, message: testCode)
                return Result.success(()).publisher.delay(for: 1, scheduler: RunLoop.main).eraseToAnyPublisher()
            default:
                viewController.showAlert(title: LinkTestResultScreenScenario.continueConfirmationAlertTitle, message: testCode)
                return Result.success(()).publisher.eraseToAnyPublisher()
            }
        }

        func reportRapidTestResultsOnGovDotUKTapped() {
            viewController.showAlert(title: LinkTestResultScreenScenario.tapReportLFDOnGovUKMessage)
        }

        func didTapCancel() {
            viewController.showAlert(title: LinkTestResultScreenScenario.cancelAlertTitle)
        }
    }
}

private struct TestError: Error {}
