//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Localization
import UIKit

public protocol NonNegativeTestResultNoIsolationViewControllerInteracting {
    var didTapOnlineServicesLink: () -> Void { get }
    var didTapPrimaryButton: () -> Void { get }
    var didTapCancel: (() -> Void)? { get }
}

extension NonNegativeTestResultNoIsolationViewController {
    private class Content: PrimaryButtonStickyFooterScrollingContent {
        init(interactor: Interacting, testResultType: TestResultType) {
            super.init(
                scrollingViews: [
                    UIImageView(.isolationEndedWarning).styleAsDecoration(),
                    BaseLabel().set(text: testResultType.headerText).styleAsPageHeader().centralized(),
                    BaseLabel().set(text: testResultType.titleText).styleAsHeading().centralized(),
                    InformationBox.indication.warning(testResultType.infoBoxText),
                    BaseLabel().set(text: testResultType.furtherAdviceText).styleAsBody(),
                    LinkButton(
                        title: localizeForCountry(.nhs111_online_link_title),
                        action: interactor.didTapOnlineServicesLink
                    ),

                ],
                primaryButton: (
                    title: testResultType.continueButtonTitle,
                    action: interactor.didTapPrimaryButton
                )
            )
        }
    }
}

public class NonNegativeTestResultNoIsolationViewController: StickyFooterScrollingContentViewController {
    public enum TestResultType {
        case void, positive
    }

    public typealias Interacting = NonNegativeTestResultNoIsolationViewControllerInteracting

    private let interactor: Interacting
    public init(interactor: Interacting, testResultType: TestResultType = .positive) {
        self.interactor = interactor
        super.init(content: Content(interactor: interactor, testResultType: testResultType))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if interactor.didTapCancel != nil {
            navigationController?.setNavigationBarHidden(false, animated: animated)
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: localize(.cancel), style: .done, target: self, action: #selector(didTapCancel))
        } else {
            navigationController?.setNavigationBarHidden(true, animated: animated)
        }
    }

    @objc func didTapCancel() {
        interactor.didTapCancel?()
    }
}

extension NonNegativeTestResultNoIsolationViewController.TestResultType {
    var headerText: String {
        switch self {
        case .positive:
            return localizeForCountry(.end_of_isolation_positive_text_no_isolation_header)
        case .void:
            return localizeForCountry(.void_test_result_no_isolation_header)
        }
    }

    var titleText: String {
        switch self {
        case .positive:
            return localizeForCountry(.end_of_isolation_positive_text_no_isolation_title)
        case .void:
            return localizeForCountry(.void_test_result_no_isolation_title)
        }
    }

    var infoBoxText: String {
        switch self {
        case .positive:
            return localizeForCountry(.end_of_isolation_do_not_isolate_after_positive_test_warning)
        case .void:
            return localizeForCountry(.void_test_result_no_isolation_warning)
        }
    }

    var furtherAdviceText: String {
        switch self {
        case .positive:
            return localizeForCountry(.end_of_isolation_further_advice_visit)
        case .void:
            return localizeForCountry(.void_test_result_no_isolation_further_advice_visit)
        }
    }

    var continueButtonTitle: String {
        switch self {
        case .positive:
            return localize(.positive_test_results_continue)
        case .void:
            return localize(.void_test_results_primary_button_title)
        }
    }
}
