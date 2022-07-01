//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol TestCheckSymptomsViewControllerInteracting {
    var didTapYes: () -> Void { get }
    var didTapNo: () -> Void { get }
}

private class TestCheckSymptomsContent: StickyFooterScrollingContent {
    typealias Interacting = TestCheckSymptomsViewControllerInteracting
    private static let infoboxInset = (.stripeWidth + .stripeSpacing)

    let scrollingContent: StackContent
    let footerContent: StackContent?
    let spacing: CGFloat = .doubleSpacing

    public init(
        viewType: TestCheckSymptomsViewController.ViewType,
        interactor: Interacting
    ) {
        scrollingContent = BasicContent(
            views: viewType.content,
            spacing: .doubleSpacing,
            margins: mutating(.largeInset) {
                $0.bottom = 0
                $0.left -= Self.infoboxInset
                $0.right -= Self.infoboxInset
            }
        )

        footerContent = BasicContent(
            views: [
                PrimaryButton(title: viewType.submitButtonText, action: {
                    interactor.didTapYes()
                }),
                SecondaryButton(title: viewType.cancelButtonText, action: {
                    interactor.didTapNo()
                }),
            ],
            spacing: .halfSpacing,
            margins: mutating(.largeInset) { $0.top = 0 }
        )
    }
}

public class TestCheckSymptomsViewController: StickyFooterScrollingContentViewController {
    public typealias Interacting = TestCheckSymptomsViewControllerInteracting

    public enum ViewType {
        case warnAndBookATest
        case enterTestResult
    }

    public static func viewController(
        for type: ViewType,
        interactor: Interacting,
        shouldHaveCancelButton: Bool = false,
        shouldConfirmCancel: Bool = false
    ) -> TestCheckSymptomsViewController {
        return TestCheckSymptomsViewController(
            viewType: type,
            interactor: interactor,
            shouldHaveCancelButton: shouldHaveCancelButton,
            shouldConfirmCancel: shouldConfirmCancel
        )
    }

    private let shouldHaveCancelButton: Bool
    private let shouldConfirmCancel: Bool

    public var didCancel: (() -> Void)?

    private let interactor: Interacting

    private init(
        viewType: ViewType,
        interactor: Interacting,
        shouldHaveCancelButton: Bool,
        shouldConfirmCancel: Bool = false
    ) {
        self.interactor = interactor
        self.shouldHaveCancelButton = shouldHaveCancelButton
        self.shouldConfirmCancel = shouldConfirmCancel
        super.init(
            content: TestCheckSymptomsContent(
                viewType: viewType,
                interactor: interactor
            )
        )
        title = viewType.titleText
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if shouldHaveCancelButton {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: localize(.cancel), style: .done, target: self, action: #selector(didTapCancel))
        }
    }

    @objc private func didTapCancel() {
        let cancelConfirmed = {
            self.didCancel?()
            self.navigationController?.dismiss(animated: true)
        }
        if shouldConfirmCancel {
            let alert = makeConfirmCancelAlert {
                cancelConfirmed()
            }
            present(alert, animated: true, completion: nil)
        } else {
            cancelConfirmed()
        }
    }

    @objc private func didTapYes() {
        interactor.didTapYes()
    }

    @objc private func didTapNo() {
        interactor.didTapNo()
    }

    private func makeConfirmCancelAlert(with action: @escaping () -> Void) -> UIAlertController {

        let alertController = UIAlertController(
            title: localize(.warn_and_test_check_symptoms_confirm_alert_title),
            message: localize(.warn_and_test_check_symptoms_confirm_alert_body),
            preferredStyle: .alert
        )

        let leaveAction = UIAlertAction(title: localize(.warn_and_test_check_symptoms_confirm_alert_leave), style: .default) { _ in action() }

        alertController.addAction(UIAlertAction(title: localize(.warn_and_test_check_symptoms_confirm_alert_stay), style: .default))
        alertController.addAction(leaveAction)

        return alertController
    }
}

private extension TestCheckSymptomsViewController.ViewType {

    var titleText: String {
        switch self {
        case .enterTestResult:
            return localize(.link_test_result_symptom_information_title)
        case .warnAndBookATest:
            return localize(.warn_and_test_check_symptoms_title)
        }
    }

    var submitButtonText: String {
        switch self {
        case .enterTestResult:
            return localize(.test_check_symptoms_yes)
        case .warnAndBookATest:
            return localize(.warn_and_test_check_symptoms_submit_button_title)
        }
    }

    var cancelButtonText: String {
        switch self {
        case .enterTestResult:
            return localize(.test_check_symptoms_no)
        case .warnAndBookATest:
            return localize(.warn_and_test_check_symptoms_cancel_button_title)
        }
    }

    var content: [StackViewContentProvider] {
        switch self {
        case .enterTestResult:
            return [
                BaseLabel().set(text: localize(.test_check_symptoms_heading)).styleAsPageHeader(),
                BulletedList(rows: localizeAndSplit(.test_check_symptoms_points)),
            ]
        case .warnAndBookATest:
            return [
                BaseLabel().set(text: localize(.warn_and_test_check_symptoms_heading)).styleAsPageHeader(),
                BaseLabel().set(text: localize(.test_check_symptoms_subheading)).styleAsBody(),
                BulletedList(rows: localizeAndSplit(.test_check_symptoms_points)),
                BaseLabel().set(text: localize(.test_check_symptoms_footer)).styleAsBody(),
            ]
        }
    }
}
