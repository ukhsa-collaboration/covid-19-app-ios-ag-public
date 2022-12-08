//
// Copyright © 2022 DHSC. All rights reserved.
//

import Common
import Localization
import SwiftUI
import UIKit

public protocol SelfReportingSelectDateViewControllerInteracting {
    func didTapPrimaryButton(selectedDay: SelectedDay)
    func didTapBackButton()
}

public class SelfReportingSelectDateViewController: UIViewController {
    public typealias Interacting = SelfReportingSelectDateViewControllerInteracting

    public enum State {
        case testDate(testKitType: TestKitType)
        case symptomsDate
    }

    private let interactor: Interacting
    private let previouslySelectedDay: SelectedDay?
    private let dateSelectionWindow: Int
    private let lastSelectionDate: GregorianDay
    private let state: State

    public init(interactor: Interacting, selectedDay: SelectedDay?, dateSelectionWindow: Int, lastSelectionDate: GregorianDay, state: State) {
        UIAccessibility.post(notification: .screenChanged, argument: state.accessibilityScreenName)
        self.interactor = interactor
        self.previouslySelectedDay = selectedDay
        self.dateSelectionWindow = dateSelectionWindow
        self.lastSelectionDate = lastSelectionDate
        self.state = state
        super.init(nibName: nil, bundle: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: localize(.back), style: .plain, target: self, action: #selector(didTapBackButton))
        navigationItem.leftBarButtonItem?.accessibilityHint = state.backButtonAccessibilityLabel
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    @objc private func didTapBackButton() {
        interactor.didTapBackButton()
    }

    private lazy var noDateLabel = BaseLabel().set(text: state.noDateLabel).styleAsBody()

    private lazy var noDateStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [noDateUnchecked, noDateChecked, noDateLabel])
        stack.alignment = .center
        stack.spacing = .standardSpacing
        stack.isUserInteractionEnabled = false
        return stack
    }()

    private lazy var noDateContainer: UIButton = {
        let button = UIButton()
        button.addFillingSubview(noDateStack)
        button.isUserInteractionEnabled = true
        button.addTarget(self, action: #selector(pickNoDate), for: .touchUpInside)
        button.isAccessibilityElement = true

        button.accessibilityLabel = state.noDateAccessabilityLabelNotChecked
        return button
    }()

    private lazy var errorBox: UIHostingController<ErrorBox> = {
        let hostingController = UIHostingController(rootView: ErrorBox(localize(.error_box_title), description: state.errorDescription))
        hostingController.view.backgroundColor = .clear
        return hostingController
    }()

    private let calendarImage: UIImageView = {
        let image = UIImageView(image: UIImage(.calendar))
        image.widthAnchor.constraint(equalToConstant: 30).isActive = true
        image.heightAnchor.constraint(equalToConstant: 30).isActive = true
        image.tintColor = UIColor(.primaryText)
        return image
    }()

    private lazy var dateLabel: UILabel = configuring(BaseLabel().styleAsBoldBody()) {
        $0.numberOfLines = 0
    }

    private lazy var dateStack: UIStackView = {
        let labels = UIView()
        labels.addFillingSubview(dateLabel)
        labels.addAutolayoutSubview(textField)
        NSLayoutConstraint.activate([
            textField.leadingAnchor.constraint(equalTo: labels.leadingAnchor),
            textField.trailingAnchor.constraint(equalTo: labels.trailingAnchor),
            textField.topAnchor.constraint(equalTo: labels.topAnchor),
        ])
        textField.alpha = 0
        let stack = UIStackView(arrangedSubviews: [labels, calendarImage])
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = .standard
        stack.alignment = .center
        stack.isUserInteractionEnabled = false
        stack.accessibilityElementsHidden = true
        return stack
    }()

    private lazy var dateContainer: UIButton = {
        let button = UIButton()
        button.addTarget(self, action: #selector(pickDate), for: .touchUpInside)
        button.addFillingSubview(dateStack)
        button.layer.borderColor = UIColor(.primaryText).cgColor
        button.layer.borderWidth = 2
        button.isUserInteractionEnabled = true
        button.accessibilityTraits = .none
        button.accessibilityLabel = state.datePlaceholderLabel
        button.accessibilityHint = state.dateHint
        return button
    }()

    private lazy var dateHeadingLabel = BaseLabel().set(text: state.headerLabel).styleAsPageHeader()

    private lazy var bulletedList = BulletedList(
        symbolProperties: SymbolProperties(type: .fullCircle, size: .halfSpacing, color: .nhsBlue),
        rows: state.bulletedList
    )

    private lazy var errorLabel: BaseLabel = {
        let label = BaseLabel()
        label.styleAsBoldBody()
        label.set(text: state.errorDescription)
        label.textColor = UIColor(.errorRed)
        return label
    }()

    private lazy var errorView: UIView = {
        let errorView = UIView()
        errorView.backgroundColor = UIColor(.errorRed)
        NSLayoutConstraint.activate([
            errorView.widthAnchor.constraint(equalToConstant: .stripeWidth),
        ])
        return errorView
    }()

    private lazy var contentStack: UIStackView = {
        var views: [UIView] = []

        switch state {
        case .testDate:
            views = [dateHeadingLabel, errorLabel, dateContainer, noDateContainer]
        case .symptomsDate:
            views = [dateHeadingLabel, bulletedList, errorLabel, dateContainer, noDateContainer]
        }

        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = .vertical
        stack.spacing = .doubleSpacing
        return stack
    }()

    private lazy var infoBox: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [errorView, contentStack])
        stack.axis = .horizontal
        stack.alignment = .fill
        stack.distribution = .fill
        stack.spacing = .stripeSpacing
        return stack
    }()

    private lazy var textField: UITextField = BaseTextField()

    private lazy var continueButton: UIButton = {
        let button = UIButton()
        button.styleAsPrimary()
        button.setTitle(localize(.continue_button_label), for: .normal)
        button.addTarget(self, action: #selector(didTapPrimaryButton), for: .touchUpInside)
        return button
    }()

    var selectedDay: SelectedDay? {
        didSet { updateDatePickerView() }
    }

    let scrollView = UIScrollView()
    let datePicker = UIPickerView()
    let noDateUnchecked = UIImageView(image: UIImage(systemName: "square"))
    let noDateChecked = UIImageView(image: UIImage(systemName: "checkmark.square.fill"))
    let toolbar = UIToolbar()

    lazy var earliestOnsetDate = lastSelectionDate - DayDuration(dateSelectionWindow - 1)

    func getDay(for row: Int) -> (GregorianDay, String) {
        let rowDate = earliestOnsetDate + DayDuration(row)
        let rowString = localize(.symptom_onset_select_day(rowDate.startDate(in: .current)))
        return (rowDate, rowString)
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        let view = self.view!
        view.styleAsScreenBackground(with: traitCollection)

        datePicker.delegate = self

        toolbar.sizeToFit()

        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: localize(.done), style: .done, target: self, action: #selector(finishDatePicking))
        doneButton.tintColor = UIColor(.nhsBlue)
        toolbar.setItems([spacer, doneButton], animated: false)

        textField.inputAccessoryView = toolbar
        textField.inputView = datePicker

        noDateUnchecked.tintColor = UIColor(.secondaryText)
        noDateUnchecked.setContentHuggingPriority(.almostRequest, for: .horizontal)

        noDateChecked.tintColor = UIColor(.nhsButtonGreen)
        noDateChecked.setContentHuggingPriority(.almostRequest, for: .horizontal)

        let containerStack = UIStackView(arrangedSubviews: [errorBox.view, infoBox, continueButton])
        containerStack.axis = .vertical
        containerStack.spacing = .doubleSpacing
        containerStack.isLayoutMarginsRelativeArrangement = true
        containerStack.layoutMargins = .standard

        scrollView.addFillingSubview(containerStack)

        view.addAutolayoutSubview(scrollView)

        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            containerStack.widthAnchor.constraint(equalTo: view.readableContentGuide.widthAnchor, multiplier: 1),
        ])

        selectedDay = previouslySelectedDay
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hideError()
    }

    private func showError() {
        errorBox.view.isHidden = false
        errorLabel.isHidden = false
        errorView.isHidden = false
        scrollView.setContentOffset(.zero, animated: true)
        UIAccessibility.post(notification: .screenChanged, argument: errorBox)
    }

    private func hideError() {
        errorBox.view.isHidden = true
        errorLabel.isHidden = true
        errorView.isHidden = true
        scrollView.setContentOffset(.zero, animated: true)
    }

    private func updateDatePickerView() {
        if let selectedDay = selectedDay {
            if selectedDay.doNotRemember {
                showDoNotRememberDate(true)
                dateLabel.text = state.datePlaceholderLabel
            } else {
                let row = dateSelectionWindow - selectedDay.day.distance(to: lastSelectionDate) - 1
                let (_, rowString) = getDay(for: row)
                dateLabel.text = rowString
                dateContainer.accessibilityValue = rowString
                datePicker.selectRow(row, inComponent: 0, animated: false)
                showDoNotRememberDate(false)
            }
        } else {
            showDoNotRememberDate(false)
            dateLabel.text = state.datePlaceholderLabel
        }
    }

    private func showDoNotRememberDate(_ doNotRememberDate: Bool) {
        if doNotRememberDate {
            noDateUnchecked.isHidden = true
            noDateChecked.isHidden = false
            noDateContainer.accessibilityLabel = state.noDateAccessabilityLabelChecked
        } else {
            noDateUnchecked.isHidden = false
            noDateChecked.isHidden = true
            noDateContainer.accessibilityLabel = state.noDateAccessabilityLabelNotChecked
        }
    }

    @objc func pickDate() {
        hideError()
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: datePicker.frame.height + toolbar.frame.height, right: 0)
        textField.becomeFirstResponder()

        if selectedDay?.doNotRemember != false {
            let (rowDate, _) = getDay(for: dateSelectionWindow - 1)
            selectedDay = SelectedDay(day: rowDate)
        }

        if #available(iOS 13.7, *) {
            UIAccessibility.post(notification: .layoutChanged, argument: datePicker)
        }
    }

    @objc func pickNoDate() {
        hideError()
        selectedDay = selectedDay?.doNotRemember == true ? nil : SelectedDay(day: lastSelectionDate, doNotRemember: true)
        dateContainer.accessibilityValue = nil
    }

    @objc func finishDatePicking() {
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        view.endEditing(true)
        continueButton.becomeFirstResponder()
        UIAccessibility.post(notification: .layoutChanged, argument: continueButton)
    }

    @objc func didTapPrimaryButton() {
        if let selectedDay = selectedDay {
            interactor.didTapPrimaryButton(selectedDay: selectedDay)
        } else {
            showError()
        }
    }
}

extension SelfReportingSelectDateViewController: UIPickerViewDelegate {

    public func numberOfComponents(in pickerView: UIPickerView) -> Int {
        1
    }

    public func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        dateSelectionWindow
    }

    public func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let (_, rowString) = getDay(for: row)
        return rowString
    }

    public func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let (rowDate, _) = getDay(for: row)
        selectedDay = SelectedDay(day: rowDate)
    }
}

extension SelfReportingSelectDateViewController: UIPickerViewDataSource {}

extension SelfReportingSelectDateViewController.State {
    var errorDescription: String {
        switch self {
        case .testDate:
            return localize(.self_report_test_date_error_description)
        case .symptomsDate:
            return localize(.self_report_symptoms_date_error_description)
        }
    }

    var headerLabel: String {
        switch self {
        case .testDate:
            return localize(.self_report_test_date_header)
        case .symptomsDate:
            return localize(.self_report_symptoms_date_header)
        }
    }

    var bulletedList: [String] {
        switch self {
        case .testDate:
            return []
        case .symptomsDate:
            return localizeAndSplit(.self_report_symptoms_date_bulleted_list)
        }
    }

    var accessibilityScreenName: String {
        switch self {
        case .testDate:
            return localize(.self_report_test_date_accessibility_title)
        case .symptomsDate:
            return localize(.self_report_symptoms_date_accessibility_title)
        }
    }

    var backButtonAccessibilityLabel: String {
        switch self {
        case .testDate(let testType):
            switch testType {
            case .labResult:
                return localize(.self_report_test_date_back_button_pcr_accessibility_label)
            case .rapidResult, .rapidSelfReported:
                return localize(.self_report_test_date_back_button_lfd_accessibility_label)
            }
        case .symptomsDate:
            return localize(.self_report_symptoms_date_back_button_accessibility_label)
        }
    }

    var noDateLabel: String {
        switch self {
        case .testDate:
            return localize(.self_report_test_date_no_date)
        case .symptomsDate:
            return localize(.self_report_symptoms_date_no_date)
        }
    }

    var noDateAccessabilityLabelNotChecked: String {
        switch self {
        case .testDate:
            return localize(.self_report_test_date_no_date_accessability_label_not_checked)
        case .symptomsDate:
            return localize(.self_report_symptoms_date_no_date_accessability_label_not_checked)
        }
    }

    var noDateAccessabilityLabelChecked: String {
        switch self {
        case .testDate:
            return localize(.self_report_test_date_no_date_accessability_label_checked)
        case .symptomsDate:
            return localize(.self_report_symptoms_date_no_date_accessability_label_checked)
        }
    }

    var datePlaceholderLabel: String {
        switch self {
        case .testDate:
            return localize(.self_report_test_date_placeholder)
        case .symptomsDate:
            return localize(.self_report_symptoms_date_placeholder)
        }
    }

    var dateHint: String {
        switch self {
        case .testDate:
            return localize(.self_report_test_date_hint)
        case .symptomsDate:
            return localize(.self_report_symptoms_date_hint)
        }
    }
}
