//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Localization
import SwiftUI
import UIKit

public enum TestSymptomsReviewUIError: Error {
    case neitherDateNorNoDateCheckSet
}

public protocol TestSymptomsReviewInteracting {
    func confirmSymptomsDate(selectedDay: GregorianDay?, hasCheckedNoDate: Bool) -> Result<Void, TestSymptomsReviewUIError>
}

public class TestSymptomsReviewViewController: UIViewController {
    public typealias Interacting = TestSymptomsReviewInteracting
    private let dateSelectionWindow: Int
    private let testEndDay: GregorianDay
    private let interactor: Interacting
    
    public init(testEndDay: GregorianDay, dateSelectionWindow: Int, interactor: Interacting) {
        self.testEndDay = testEndDay
        self.dateSelectionWindow = dateSelectionWindow
        self.interactor = interactor
        super.init(nibName: nil, bundle: nil)
        title = localize(.link_test_result_symptom_information_title)
        navigationItem.hidesBackButton = true
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let noDateLabel = BaseLabel().styleAsBody().set(text: localize(.symptom_review_no_date))
    
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
        
        button.accessibilityLabel = localize(.symptom_review_no_date_accessability_label_not_checked)
        return button
    }()
    
    private lazy var errorBox: ErrorBox = {
        ErrorBox(localize(.symptom_list_error_heading), description: localize(.symptom_review_error_description))
    }()
    
    private lazy var errorBoxVC: UIHostingController<ErrorBox> = {
        UIHostingController(rootView: errorBox)
    }()
    
    private let calendarImage: UIImageView = {
        let image = UIImageView(image: UIImage(.calendar))
        #warning("Set the correct image size")
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
        button.accessibilityLabel = localize(.symptom_review_date_placeholder)
        button.accessibilityHint = localize(.symptom_review_date_hint)
        return button
    }()
    
    private lazy var dateInfoBox = InformationBox.error(dateContainer, noDateContainer)
    
    private lazy var textField: UITextField = BaseTextField()
    
    private lazy var confirmButton: UIButton = {
        let confirmButton = UIButton()
        confirmButton.styleAsPrimary()
        confirmButton.setTitle(localize(.test_symptoms_date_continue), for: .normal)
        confirmButton.addTarget(self, action: #selector(confirmSymptoms), for: .touchUpInside)
        return confirmButton
    }()
    
    var selectedDay: GregorianDay? {
        didSet {
            if selectedDay != nil {
                noDateUnchecked.isHidden = false
                noDateChecked.isHidden = true
            }
        }
    }
    
    let scrollView = UIScrollView()
    let datePicker = UIPickerView()
    let noDateUnchecked = UIImageView(image: UIImage(systemName: "square"))
    let noDateChecked = UIImageView(image: UIImage(systemName: "checkmark.square.fill"))
    let toolbar = UIToolbar()
    
    lazy var earliestOnsetDate = testEndDay - DayDuration(dateSelectionWindow - 1)
    
    func getDay(for row: Int) -> (GregorianDay, String) {
        let rowDate = earliestOnsetDate + DayDuration(row)
        let rowString = localize(.symptom_onset_select_day(rowDate.startDate(in: .current)))
        return (rowDate, rowString)
    }
    
    func layoutStack(children: [UIView]) -> UIStackView {
        mutating(UIStackView(arrangedSubviews: children)) {
            $0.axis = .vertical
            $0.spacing = .doubleSpacing
            $0.isLayoutMarginsRelativeArrangement = true
            $0.layoutMargins = .standard
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let view = self.view!
        view.styleAsScreenBackground(with: traitCollection)
        
        let heading = BaseLabel().styleAsPageHeader().set(text: localize(.test_symptoms_date_heading))
        let symptomPoints = BulletedList(rows: localizeAndSplit(.test_check_symptoms_points))
        
        datePicker.delegate = self
        
        toolbar.sizeToFit()
        
        let spacer = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        let doneButton = UIBarButtonItem(title: localize(.done), style: .done, target: self, action: #selector(finishDatePicking))
        doneButton.tintColor = UIColor(.nhsBlue)
        toolbar.setItems([spacer, doneButton], animated: false)
        
        textField.inputAccessoryView = toolbar
        textField.inputView = datePicker
        
        dateLabel.text = localize(.symptom_review_date_placeholder)
        
        let calendarImage = UIImageView(image: UIImage(.calendar))
        calendarImage.widthAnchor.constraint(equalTo: calendarImage.heightAnchor).isActive = true
        calendarImage.tintColor = UIColor(.primaryText)
        
        noDateUnchecked.tintColor = UIColor(.secondaryText)
        noDateUnchecked.setContentHuggingPriority(.almostRequest, for: .horizontal)
        
        noDateChecked.tintColor = UIColor(.nhsButtonGreen)
        noDateChecked.setContentHuggingPriority(.almostRequest, for: .horizontal)
        noDateChecked.isHidden = true
        
        errorBoxVC.view.backgroundColor = .clear
        
        let symptomOptionStack = layoutStack(children: [errorBoxVC.view, heading, symptomPoints])
        let buttonStack = layoutStack(children: [confirmButton])
        let containerStack = layoutStack(children: [symptomOptionStack, dateInfoBox, buttonStack])
        
        scrollView.addFillingSubview(containerStack)
        
        view.addAutolayoutSubview(scrollView)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: view.bottomAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            containerStack.widthAnchor.constraint(equalTo: view.readableContentGuide.widthAnchor, multiplier: 1),
        ])
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        errorBoxVC.view.isHidden = true
    }
    
    @objc func pickDate() {
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: datePicker.frame.height + toolbar.frame.height, right: 0)
        textField.becomeFirstResponder()
        
        if selectedDay == nil {
            let row = dateSelectionWindow - 1
            let (rowDate, rowString) = getDay(for: row)
            selectedDay = rowDate
            dateLabel.text = rowString
            dateContainer.accessibilityValue = rowString
            datePicker.selectRow(row, inComponent: 0, animated: false)
        }
        
        if #available(iOS 13.7, *) {
            UIAccessibility.post(notification: .layoutChanged, argument: datePicker)
        }
    }
    
    @objc func pickNoDate() {
        noDateUnchecked.isHidden.toggle()
        noDateChecked.isHidden.toggle()
        if selectedDay != nil {
            selectedDay = nil
            dateLabel.text = localize(.symptom_review_date_placeholder)
        }
        
        if noDateChecked.isHidden {
            noDateContainer.accessibilityLabel = localize(.symptom_review_no_date_accessability_label_not_checked)
        } else {
            noDateContainer.accessibilityLabel = localize(.symptom_review_no_date_accessability_label_checked)
        }
        
    }
    
    @objc func finishDatePicking() {
        scrollView.contentInset = UIEdgeInsets(top: 0, left: 0, bottom: 0, right: 0)
        view.endEditing(true)
        confirmButton.becomeFirstResponder()
        UIAccessibility.post(notification: .layoutChanged, argument: confirmButton)
    }
    
    @objc func confirmSymptoms() {
        switch interactor.confirmSymptomsDate(selectedDay: selectedDay, hasCheckedNoDate: noDateUnchecked.isHidden) {
        case .success(()):
            break
        case .failure:
            errorBoxVC.view.isHidden = false
            scrollView.setContentOffset(.zero, animated: true)
            dateInfoBox.error()
            UIAccessibility.post(notification: .layoutChanged, argument: errorBoxVC)
        }
    }
}

extension TestSymptomsReviewViewController: UIPickerViewDelegate {
    
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
        let (rowDate, rowString) = getDay(for: row)
        selectedDay = rowDate
        dateLabel.text = rowString
        dateContainer.accessibilityValue = rowString
    }
}

extension TestSymptomsReviewViewController: UIPickerViewDataSource {}
