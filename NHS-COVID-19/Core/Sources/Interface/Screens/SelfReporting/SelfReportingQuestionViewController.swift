//
// Copyright © 2022 DHSC. All rights reserved.
//

import Localization
import SwiftUI
import UIKit
import Common

public protocol SelfReportingQuestionViewControllerInteracting {
    func didTapPrimaryButton(_ firstChoice: Bool)
    func didTapBackButton()
}

private class Content {
    var views: [StackViewContentProvider]

    public typealias Interacting = SelfReportingQuestionViewControllerInteracting

    public init(interactor: Interacting, firstChoice: Bool?, state: SelfReportingQuestionViewController.State) {
        var firstChoice: Bool? = firstChoice

        let emptyError = UIHostingController(
            rootView: ErrorBox(
                localize(.error_box_title),
                description: state.errorDescription
            )
        )
        emptyError.view.backgroundColor = .clear
        emptyError.view.isHidden(true)

        let errorLabel = BaseLabel().set(text: state.errorDescription)
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

        let headerLabel = BaseLabel().set(text: state.headerLabel).styleAsPageHeader()

        let bulletedListHeader = BaseLabel().set(text: state.bulletedListHeader).styleAsBody()

        let bulletedList = BulletedList(
            symbolProperties: SymbolProperties(type: .fullCircle, size: .halfSpacing, color: .nhsBlue),
            rows: state.bulletedList
        )

        let description = BaseLabel().set(text: state.description).styleAsBody()

        let firstRadioButton: RadioButtonGroup.ButtonViewModel = .init(
            title: state.firstRadioButtonTitle,
            action: {
                firstChoice = true
                hideError()
            }
        )

        let secondRadioButton: RadioButtonGroup.ButtonViewModel = .init(
            title: state.secondRadioButtonTitle,
            action: {
                firstChoice = false
                hideError()
            }
        )

        var radioButtonState: RadioButtonGroup.State {
            guard let firstChoice = firstChoice else {
                return RadioButtonGroup.State()
            }

            if firstChoice {
                return RadioButtonGroup.State(selectedID: firstRadioButton.id)
            } else {
                return RadioButtonGroup.State(selectedID: secondRadioButton.id)
            }
        }

        let radioButtonGroup = UIHostingController(rootView: RadioButtonGroup(
            buttonViewModels: [firstRadioButton, secondRadioButton],
            state: radioButtonState,
            alignment: state.radioButtonAlignment
        ))
        radioButtonGroup.view.backgroundColor = .clear

        let primaryButton = PrimaryButton(
            title: localize(.continue_button_label),
            action: {
                if let firstChoice = firstChoice {
                    interactor.didTapPrimaryButton(firstChoice)
                } else {
                    showError()
                }
            }
        )

        var questionViews: [UIView] = []
        switch state {
        case .testKitType:
            questionViews = [
                headerLabel,
                description,
                errorLabel,
                radioButtonGroup.view
            ]
        case .testSupplier:
            questionViews = [
                headerLabel,
                bulletedListHeader,
                bulletedList,
                description,
                errorLabel,
                radioButtonGroup.view
            ]
        case .symptoms:
            questionViews = [
                headerLabel,
                bulletedList,
                errorLabel,
                radioButtonGroup.view
            ]
        case .reportedResult:
            questionViews = [
                headerLabel,
                description,
                errorLabel,
                radioButtonGroup.view
            ]
        }

        let questionStack = UIStackView(arrangedSubviews: questionViews)
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

        let stackView = UIStackView(arrangedSubviews: [contentStack, primaryButton, SpacerView()])
        stackView.axis = .vertical
        stackView.spacing = .tripleSpacing

        views = [stackView]
    }
}

public class SelfReportingQuestionViewController: ScrollingContentViewController {
    public enum State {
        case testKitType(keysShared: Bool)
        case testSupplier
        case symptoms
        case reportedResult(symptoms: Bool?)
    }

    public typealias Interacting = SelfReportingQuestionViewControllerInteracting
    private let interactor: Interacting

    public init(interactor: Interacting, firstChoice: Bool?, state: State) {
        UIAccessibility.post(notification: .screenChanged, argument: state.accessibilityScreenName)
        self.interactor = interactor
        super.init(views: Content(interactor: interactor, firstChoice: firstChoice, state: state).views)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: localize(.back), style: .plain, target: self, action: #selector(didTapBackButton))
        navigationItem.leftBarButtonItem?.accessibilityHint = state.backButtonAccessibilityLabel
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

extension SelfReportingQuestionViewController.State {
    var errorDescription: String {
        switch self {
        case .testKitType:
            return localize(.self_report_test_kit_type_error_description)
        case .testSupplier:
            return localize(.self_report_test_supplier_error_description)
        case .symptoms:
            return localize(.self_report_symptoms_error_description)
        case .reportedResult:
            return localize(.self_report_reported_result_error_description)
        }
    }

    var headerLabel: String {
        switch self {
        case .testKitType:
            return localize(.self_report_test_kit_type_header)
        case .testSupplier:
            return localize(.self_report_test_supplier_header)
        case .symptoms:
            return localize(.self_report_symptoms_header)
        case .reportedResult:
            return localize(.self_report_reported_result_header)
        }
    }

    var bulletedListHeader: String? {
        switch self {
        case .testSupplier:
            return localize(.self_report_test_supplier_bulleted_list_header)
        case .testKitType, .symptoms, .reportedResult:
            return nil
        }
    }

    var bulletedList: [String] {
        switch self {
        case .testSupplier:
            return localizeAndSplit(.self_report_test_supplier_bulleted_list)
        case .testKitType, .reportedResult:
            return []
        case .symptoms:
            return localizeAndSplit(.self_report_symptoms_bulleted_list)
        }
    }

    var description: String? {
        switch self {
        case .testKitType:
            return localize(.self_report_test_kit_type_description)
        case .testSupplier:
            return localize(.self_report_test_supplier_description)
        case .symptoms:
            return nil
        case .reportedResult:
            return localize(.self_report_reported_result_body)
        }
    }

    var firstRadioButtonTitle: String {
        switch self {
        case .testKitType:
            return localize(.self_report_test_kit_type_radio_button_option_lfd)
        case .testSupplier:
            return localize(.self_report_test_supplier_first_radio_button_label)
        case .symptoms:
            return localize(.self_report_symptoms_radio_button_option_yes)
        case .reportedResult:
            return localize(.self_report_reported_result_radio_button_option_yes)
        }
    }

    var secondRadioButtonTitle: String {
        switch self {
        case .testKitType:
            return localize(.self_report_test_kit_type_radio_button_option_pcr)
        case .testSupplier:
            return localize(.self_report_test_supplier_second_radio_button_label)
        case .symptoms:
            return localize(.self_report_symptoms_radio_button_option_no)
        case .reportedResult:
            return localize(.self_report_reported_result_radio_button_option_no)
        }
    }

    var radioButtonAlignment: RadioButtonGroup.RadioButtonAlignment {
        switch self {
        case .testKitType, .testSupplier, .reportedResult:
            return .vertical
        case .symptoms:
            return .horizontal
        }
    }

    var accessibilityScreenName: String {
        switch self {
        case .testKitType:
            return localize(.self_report_test_kit_type_accessibility_title)
        case .testSupplier:
            return localize(.self_report_test_supplier_accessibility_title)
        case .symptoms:
            return localize(.self_report_symptoms_accessibility_title)
        case .reportedResult:
            return localize(.self_report_reported_result_accessibility_title)
        }
    }

    var backButtonAccessibilityLabel: String {
        switch self {
        case .testKitType(let sharedKeys):
            if sharedKeys {
                return localize(.self_report_test_kit_type_back_button_accessibility_label)
            } else {
                return localize(.self_report_test_kit_type_back_button_did_not_share_keys_accessibility_label)
            }
        case .testSupplier:
            return localize(.self_report_test_supplier_back_button_accessibility_label)
        case .symptoms:
            return localize(.self_report_symptoms_back_button_accessibility_label)
        case .reportedResult(let hadSymptoms):
            if hadSymptoms == nil {
                return localize(.self_report_reported_result_test_date_back_button_accessibility_label)
            } else if hadSymptoms == true {
                return localize(.self_report_reported_result_symptoms_start_date_back_button_accessibility_label)
            } else {
                return localize(.self_report_reported_result_symptoms_back_button_accessibility_label)
            }
        }
    }
}
