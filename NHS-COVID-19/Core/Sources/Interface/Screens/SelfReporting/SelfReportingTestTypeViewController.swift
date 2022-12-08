//
// Copyright © 2022 DHSC. All rights reserved.
//

import Localization
import SwiftUI
import UIKit
import Common

public protocol SelfReportingTestTypeViewControllerInteracting {
    func didTapPrimaryButton(_ testResult: TestResult)
    func didTapBackButton()
}

struct SelfReportingTestTypeContent {
    public typealias Interacting = SelfReportingTestTypeViewControllerInteracting
    var views: [StackViewContentProvider]

    init(interactor: Interacting, testResult: TestResult?) {
        var testResult: TestResult? = testResult

        let emptyError = UIHostingController(
            rootView: ErrorBox(
                localize(.error_box_title),
                description: localize(.self_report_test_type_error_description)
            )
        )
        emptyError.view.backgroundColor = .clear
        emptyError.view.isHidden(true)

        let errorLabel = BaseLabel().set(text: localize(.self_report_test_type_error_description)).styleAsBody()
        errorLabel.styleAsBoldBody()
        errorLabel.textColor = UIColor(.errorRed)
        errorLabel.isHidden(true)

        let errorView = UIView()
        errorView.backgroundColor = UIColor(.errorRed)
        errorView.isHidden = true

        func hideError() {
            emptyError.view.isHidden = true
            errorLabel.isHidden = true
            errorView.isHidden = true
        }

        func showError() {
            emptyError.view.isHidden = false
            errorLabel.isHidden = false
            errorView.isHidden = false
            UIAccessibility.post(notification: .screenChanged, argument: emptyError)
        }

        let titleLabel = BaseLabel().set(text: localize(.self_report_test_type_header)).styleAsPageHeader()

        let positiveRadioButton: RadioButtonGroup.ButtonViewModel = .init(
            title: localize(.self_report_test_type_radio_button_option_positive),
            action: {
                hideError()
                testResult = .positive
            }
        )
        let negativeRadioButton: RadioButtonGroup.ButtonViewModel = .init(
            title: localize(.self_report_test_type_radio_button_option_negative),
            action: {
                hideError()
                testResult = .negative
            }
        )
        let voidRadioButton: RadioButtonGroup.ButtonViewModel = .init(
            title: localize(.self_report_test_type_radio_button_option_void),
            action: {
                hideError()
                testResult = .void
            }
        )

        var radioButtonState: RadioButtonGroup.State {
            guard let testResult = testResult else {
                return RadioButtonGroup.State()
            }

            switch testResult {
            case .positive:
                return RadioButtonGroup.State(selectedID: positiveRadioButton.id)
            case .negative:
                return RadioButtonGroup.State(selectedID: negativeRadioButton.id)
            case .void:
                return RadioButtonGroup.State(selectedID: voidRadioButton.id)
            }
        }

        let radioButtonGroup = UIHostingController(rootView: RadioButtonGroup(
            buttonViewModels: [positiveRadioButton, negativeRadioButton, voidRadioButton],
            state: radioButtonState,
            alignment: .vertical
        ))
        radioButtonGroup.view.backgroundColor = .clear

        let questionStack = UIStackView(arrangedSubviews: [titleLabel, errorLabel, radioButtonGroup.view])
        questionStack.axis = .vertical
        questionStack.spacing = .doubleSpacing

        NSLayoutConstraint.activate([
            errorView.widthAnchor.constraint(equalToConstant: .stripeWidth),
        ])

        let errorStack = UIStackView(arrangedSubviews: [errorView, questionStack])
        errorStack.axis = .horizontal
        errorStack.alignment = .fill
        errorStack.distribution = .fill
        errorStack.spacing = .stripeSpacing

        let contentStack = UIStackView(arrangedSubviews: [emptyError.view, errorStack])
        contentStack.axis = .vertical
        contentStack.spacing = .standardSpacing

        let primaryButton = PrimaryButton(
            title: localize(.continue_button_label),
            action: {
                if let testResult = testResult {
                    interactor.didTapPrimaryButton(testResult)
                } else {
                    showError()
                }
            }
        )

        let stackView = UIStackView(arrangedSubviews: [contentStack, primaryButton, SpacerView()])
        stackView.axis = .vertical
        stackView.spacing = .tripleSpacing

        views = [stackView]
    }
}

public class SelfReportingTestTypeViewController: ScrollingContentViewController {
    public typealias Interacting = SelfReportingTestTypeViewControllerInteracting
    private let interactor: Interacting

    public init(interactor: Interacting, testResult: TestResult?) {
        UIAccessibility.post(notification: .screenChanged, argument: localize(.self_report_test_type_title))
        self.interactor = interactor
        let content = SelfReportingTestTypeContent(interactor: interactor, testResult: testResult)
        super.init(views: content.views)
        title = localize(.self_report_test_type_title)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: localize(.back), style: .plain, target: self, action: #selector(didTapBackButton))
        navigationItem.leftBarButtonItem?.accessibilityHint = localize(.self_report_test_type_back_button_accessibility_label)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }

    @objc private func didTapBackButton() {
        interactor.didTapBackButton()
    }
}
