//
// Copyright © 2022 DHSC. All rights reserved.
//

import Localization
import SwiftUI
import UIKit
import Common

public protocol SelfReportingCheckAnswersViewControllerInteracting {
    func didTapPrimaryButton()
    func didTapBackButton()
    func didTapChangeTestKitType()
    func didTapChangeTestSupplier()
    func didTapChangeTestDay()
    func didTapChangeSymptoms()
    func didTapChangeSymptomsDay()
    func didTapChangeReportedResult()
}

public class SelfReportQuestionSummary {
    let questionLabel: String
    let answerLabel: String
    let bulletedList: [String]?
    let changeButtonAccessibilityLabel: String
    let changeButtonAction: () -> Void

    public init(questionLabel: String, answerLabel: String, bulletedList: [String]? = nil, changeButtonAccessibilityLabel: String, changeButtonAction: @escaping () -> Void) {
        self.questionLabel = questionLabel
        self.answerLabel = answerLabel
        self.bulletedList = bulletedList
        self.changeButtonAccessibilityLabel = changeButtonAccessibilityLabel
        self.changeButtonAction = changeButtonAction
    }
}

public class SelfReportingCheckAnswersViewController: UIViewController {
    public typealias Interacting = SelfReportingCheckAnswersViewControllerInteracting
    private let interactor: Interacting
    private let info: SelfReportingInfo

    public init(interactor: Interacting, info: SelfReportingInfo) {
        UIAccessibility.post(notification: .screenChanged, argument: localize(.self_report_check_answers_accessibility_title))
        self.interactor = interactor
        self.info = info
        super.init(nibName: nil, bundle: nil)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: localize(.back), style: .plain, target: self, action: #selector(didTapBackButton))
        navigationItem.leftBarButtonItem?.accessibilityHint = {
            if info.reportedResult != nil {
                return localize(.self_report_check_answers_back_button_accessibility_label)
            } else if info.symptoms == nil {
                return localize(.self_report_check_answers_test_date_back_button_accessibility_label)
            } else if info.symptoms == true {
                return localize(.self_report_check_answers_symptoms_start_date_back_button_accessibility_label)
            } else {
                return localize(.self_report_check_answers_symptoms_back_button_accessibility_label)
            }
        }()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
    }

    let scrollView = UIScrollView()

    func questionSection(_ summary: SelfReportQuestionSummary) -> UIStackView {
        let questionLabel = BaseLabel().set(text: summary.questionLabel).styleAsBoldBody()
        let answerLabel = BaseLabel().set(text: summary.answerLabel).styleAsBody()

        let changeButton = LinkButton(
            title: localize(.self_report_check_answers_change_link_label),
            accessoryImage: nil,
            externalLink: false,
            action: summary.changeButtonAction
        )
        changeButton.accessibilityLabel = summary.changeButtonAccessibilityLabel

        let divider = UIView()
        divider.backgroundColor = UIColor(.borderColor)
        divider.heightAnchor.constraint(equalToConstant: 1).isActive = true

        var views = [UIView]()

        if let bulletedRows = summary.bulletedList {
            let bulletedList = BulletedList(
                symbolProperties: .init(type: .fullCircle, size: .hairSpacing, color: .primaryText),
                rows: bulletedRows,
                stackSpaceing: .halfHairSpacing,
                boldText: true
            )
            views = [questionLabel, bulletedList, answerLabel, changeButton, divider]
        } else {
            views = [questionLabel, answerLabel, changeButton, divider]
        }

        let stack = UIStackView(arrangedSubviews: views)
        stack.axis = .vertical
        stack.spacing = .halfSpacing
        return stack
    }

    private func testDayLabel(for testDay: SelectedDay) -> String {
        if testDay.doNotRemember {
            return localize(.self_report_test_date_no_date)
        }
        return localize(.symptom_onset_select_day(testDay.day.startDate(in: .current)))
    }

    override public func viewDidLoad() {
        super.viewDidLoad()

        let view = self.view!
        view.styleAsScreenBackground(with: traitCollection)

        var questions = [SelfReportQuestionSummary]()

        if let testKitType = info.testKitType {
            questions.append(SelfReportQuestionSummary(
                questionLabel: localize(.self_report_test_kit_type_header),
                answerLabel: localize(testKitType == .labResult
                                      ? .self_report_test_kit_type_radio_button_option_pcr
                                      : .self_report_test_kit_type_radio_button_option_lfd),
                changeButtonAccessibilityLabel: localize(.self_report_check_answers_test_type_change_link_accessibility_label),
                changeButtonAction: interactor.didTapChangeTestKitType
            ))
        }

        if let nhsTest = info.nhsTest {
            questions.append(SelfReportQuestionSummary(
                questionLabel: localize(.self_report_test_supplier_header),
                answerLabel: localize(nhsTest
                                      ? .self_report_test_supplier_first_radio_button_label
                                      : .self_report_test_supplier_second_radio_button_label),
                changeButtonAccessibilityLabel: localize(.self_report_check_answers_test_supplier_change_link_accessibility_label),
                changeButtonAction: interactor.didTapChangeTestSupplier
            ))
        }

        if let testDay = info.testDay {
            questions.append(SelfReportQuestionSummary(
                questionLabel: localize(.self_report_test_date_header),
                answerLabel: testDayLabel(for: testDay),
                changeButtonAccessibilityLabel: localize(.self_report_check_answers_test_date_change_link_accessibility_label),
                changeButtonAction: interactor.didTapChangeTestDay
            ))
        }

        if let symptoms = info.symptoms {
            questions.append(SelfReportQuestionSummary(
                questionLabel: localize(.self_report_symptoms_header),
                answerLabel: localize(symptoms ? .self_report_symptoms_radio_button_option_yes : .self_report_symptoms_radio_button_option_no),
                bulletedList: localizeAndSplit(.self_report_symptoms_bulleted_list),
                changeButtonAccessibilityLabel: localize(.self_report_check_answers_symptoms_change_link_accessibility_label),
                changeButtonAction: interactor.didTapChangeSymptoms
            ))
        }

        if let symptomsDay = info.symptomsDay {
            questions.append(SelfReportQuestionSummary(
                questionLabel: localize(.self_report_symptoms_date_header),
                answerLabel: testDayLabel(for: symptomsDay),
                changeButtonAccessibilityLabel: localize(.self_report_check_answers_symptoms_date_change_link_accessibility_label),
                changeButtonAction: interactor.didTapChangeSymptomsDay
            ))
        }

        if let reportedResult = info.reportedResult {
            questions.append(SelfReportQuestionSummary(
                questionLabel: localize(.self_report_reported_result_header),
                answerLabel: localize(reportedResult ? .self_report_reported_result_radio_button_option_yes : .self_report_reported_result_radio_button_option_no),
                changeButtonAccessibilityLabel: localize(.self_report_check_answers_reported_result_change_link_accessibility_label),
                changeButtonAction: interactor.didTapChangeReportedResult
            ))
        }

        let contentView = UIStackView(arrangedSubviews: questions.map { questionSection($0) })
        contentView.axis = .vertical
        contentView.spacing = .tripleSpacing

        let headerLabel = BaseLabel().set(text: localize(.self_report_check_answers_header)).styleAsPageHeader()

        let primaryButton = PrimaryButton(
            title: localize(.self_report_check_answers_primary_button),
            action: { self.interactor.didTapPrimaryButton() }
        )

        let containerStack = UIStackView(arrangedSubviews: [headerLabel, contentView, primaryButton, SpacerView()])
        containerStack.axis = .vertical
        containerStack.spacing = .tripleSpacing
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
    }

    @objc private func didTapBackButton() {
        interactor.didTapBackButton()
    }
}
