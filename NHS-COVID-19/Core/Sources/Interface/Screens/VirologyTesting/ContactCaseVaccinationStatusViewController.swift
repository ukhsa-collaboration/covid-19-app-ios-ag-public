//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Localization
import SwiftUI

public protocol ContactCaseVaccinationStatusViewControllerInteracting {
    func didTapAboutApprovedVaccinesLink()
    func didTapConfirm(answers: ContactCaseVaccinationStatusAnswers) -> Result<Void, ContactCaseVaccinationStatusNotEnoughAnswersError>
    func didAnswerQuestion(answers: ContactCaseVaccinationStatusAnswers) -> [ContactCaseVaccinationStatusQuestion]
}

public struct ContactCaseVaccinationStatusAnswers {
    public var fullyVaccinated: Bool?
    public var lastDose: Bool?
    public var clinicalTrial: Bool?
    public var medicallyExempt: Bool?
}

public enum ContactCaseVaccinationStatusQuestion {
    case fullyVaccinated
    case lastDose
    case clinicalTrial
    case medicallyExempt
}

public class ContactCaseVaccinationStatusNotEnoughAnswersError: Error {
    public init() {}
}

class ContactCaseVaccinationStatusContent {
    public typealias Interacting = ContactCaseVaccinationStatusViewControllerInteracting

    var scrollTo: (UIView) -> Void = { _ in }

    private let interactor: Interacting
    private let vaccineThresholdDate: Date
    private let isIndexCase: Bool
    private var cancellables: Set<AnyCancellable> = []

    private var hasReceivedAllVaccineDosesSubject: Bool?
    private var isLastVaccineDoseTimeValid: Bool?
    private var clinicalTrial: Bool?
    private var medicallyExemptEnd: Bool?
    private var medicallyExemptMiddle: Bool?
    private var medicallyExempt: Bool? {
        if medicallyExemptMiddle == nil, medicallyExemptEnd == nil {
            return nil
        } else {
            return medicallyExemptEnd ?? false || medicallyExemptMiddle ?? false
        }
    }

    private lazy var allApprovedDosesRadioButtonGroup: UIHostingController<RadioButtonGroup> = makeRadioButtonView(
        yesTitle: localize(.contact_case_vaccination_status_all_doses_of_vaccine_yes_option),
        yesAccessibility: localize(.contact_case_vaccination_status_all_doses_of_vaccine_yes_option_accessibility_text),
        yesAction: { [weak self] in
            self?.hasReceivedAllVaccineDosesSubject = true
            self?.resetLastDose()
            self?.resetClinicalTrial()
            self?.resetMedicallyExemptEnd()
            self?.resetMedicallyExemptMiddle()
        },
        noTitle: localize(.contact_case_vaccination_status_all_doses_of_vaccine_no_option),
        noAccessibility: localize(.contact_case_vaccination_status_all_doses_of_vaccine_no_option_accessibility_text),
        noAction: { [weak self] in
            self?.hasReceivedAllVaccineDosesSubject = false
            self?.resetLastDose()
            self?.resetClinicalTrial()
            self?.resetMedicallyExemptEnd()
            self?.resetMedicallyExemptMiddle()
        }
    )

    private lazy var lastDoseDateRadioButtonGroup: UIHostingController<RadioButtonGroup> = makeRadioButtonView(
        yesTitle: localize(.contact_case_vaccination_status_last_dose_of_vaccine_yes_option),
        yesAccessibility: localize(.contact_case_vaccination_status_last_dose_of_vaccine_yes_option_accessibility_text(date: vaccineThresholdDate)),
        yesAction: { [weak self] in
            self?.isLastVaccineDoseTimeValid = true
            self?.resetClinicalTrial()
            self?.resetMedicallyExemptEnd()
            self?.resetMedicallyExemptMiddle()
        },
        noTitle: localize(.contact_case_vaccination_status_last_dose_of_vaccine_no_option),
        noAccessibility: localize(.contact_case_vaccination_status_last_dose_of_vaccine_no_option_accessibility_text(date: vaccineThresholdDate)),
        noAction: { [weak self] in
            self?.isLastVaccineDoseTimeValid = false
            self?.resetClinicalTrial()
            self?.resetMedicallyExemptEnd()
            self?.resetMedicallyExemptMiddle()
        }
    )

    private lazy var medicallyExemptMiddleRadioButtonGroup: UIHostingController<RadioButtonGroup> = makeRadioButtonView(
        yesTitle: localize(.exposure_notification_medically_exempt_yes),
        yesAccessibility: localize(.exposure_notification_medically_exempt_yes_content_description),
        yesAction: { [weak self] in
            self?.medicallyExemptMiddle = true
            self?.resetClinicalTrial()
            self?.resetMedicallyExemptEnd()
        },
        noTitle: localize(.exposure_notification_medically_exempt_no),
        noAccessibility: localize(.exposure_notification_medically_exempt_no_content_description),
        noAction: { [weak self] in
            self?.medicallyExemptMiddle = false
            self?.resetClinicalTrial()
            self?.resetMedicallyExemptEnd()
        }
    )

    private lazy var clinicalTrialRadioButtonGroup: UIHostingController<RadioButtonGroup> = makeRadioButtonView(
        yesTitle: localize(.exposure_notification_clinical_trial_yes),
        yesAccessibility: localize(.exposure_notification_clinical_trial_yes_content_description),
        yesAction: { [weak self] in
            self?.clinicalTrial = true
            self?.resetMedicallyExemptEnd()
        },
        noTitle: localize(.exposure_notification_clinical_trial_no),
        noAccessibility: localize(.exposure_notification_clinical_trial_no_content_description),
        noAction: { [weak self] in
            self?.clinicalTrial = false
            self?.resetMedicallyExemptEnd()
        }
    )

    private lazy var medicallyExemptEndRadioButtonGroup: UIHostingController<RadioButtonGroup> = makeRadioButtonView(
        yesTitle: localize(.exposure_notification_medically_exempt_yes),
        yesAccessibility: localize(.exposure_notification_medically_exempt_yes_content_description),
        yesAction: { [weak self] in self?.medicallyExemptEnd = true },
        noTitle: localize(.exposure_notification_medically_exempt_no),
        noAccessibility: localize(.exposure_notification_medically_exempt_no_content_description),
        noAction: { [weak self] in self?.medicallyExemptEnd = false }
    )

    private lazy var lastDoseDateQuestionHeading: BaseLabel = {
        BaseLabel()
            .styleAsSecondaryTitle()
            .set(text: localize(.contact_case_vaccination_status_last_dose_of_vaccine_question(date: vaccineThresholdDate)))
            .isHidden(true)
    }()

    private lazy var medicallyExemptMiddleQuestionHeading: BaseLabel = {
        BaseLabel()
            .styleAsSecondaryTitle()
            .set(text: localize(.exposure_notification_medically_exempt_question))
            .isHidden(true)
    }()

    private lazy var medicallyExemptMiddleQuestionDescription: BaseLabel = {
        BaseLabel()
            .styleAsBody()
            .set(text: localize(.exposure_notification_medically_exempt_description))
            .isHidden(true)
    }()

    private lazy var clinicalTrialQuestionHeading: BaseLabel = {
        BaseLabel()
            .styleAsSecondaryTitle()
            .set(text: localize(.exposure_notification_clinical_trial_question))
            .isHidden(true)
    }()

    private lazy var medicallyExemptEndQuestionHeading: BaseLabel = {
        BaseLabel()
            .styleAsSecondaryTitle()
            .set(text: localize(.exposure_notification_medically_exempt_question))
            .isHidden(true)
    }()

    private lazy var medicallyExemptEndQuestionDescription: BaseLabel = {
        BaseLabel()
            .styleAsBody()
            .set(text: localize(.exposure_notification_medically_exempt_description))
            .isHidden(true)
    }()

    private lazy var emptyError: UIHostingController<ErrorBox> = {
        let emptyError = UIHostingController(
            rootView: ErrorBox(
                localize(.contact_case_vaccination_status_error_title),
                description: localize(.contact_case_vaccination_status_error_description)
            )
        )
        emptyError.view.backgroundColor = .clear
        emptyError.view.isHidden(true)
        return emptyError
    }()

    init(interactor: Interacting, vaccineThresholdDate: Date, isIndexCase: Bool) {
        self.interactor = interactor
        self.vaccineThresholdDate = vaccineThresholdDate
        self.isIndexCase = isIndexCase
    }

    func makeViews() -> [StackViewContentProvider] {

        // Always show the first question
        allApprovedDosesRadioButtonGroup.view.isHidden = false

        var stackedViews: [UIView] = [
            UIImageView(.isolationContinue)
                .styleAsDecoration(),
            BaseLabel()
                .styleAsPageHeader()
                .set(text: localize(.contact_case_vaccination_status_heading))
                .centralized(),
        ]

        if !isIndexCase {
            stackedViews.append(contentsOf: [
                BaseLabel()
                    .styleAsBody()
                    .set(text: localize(.contact_case_vaccination_status_description)),
            ])
        }

        stackedViews.append(contentsOf: [
            emptyError.view,
            BaseLabel()
                .styleAsSecondaryTitle()
                .set(text: localize(.contact_case_vaccination_status_all_doses_of_vaccine_question)),
            BaseLabel()
                .styleAsBody()
                .set(text: localize(.contact_case_vaccination_status_all_doses_of_vaccine_description)),
            LinkButton(
                title: localize(.contact_case_vaccination_status_aproved_vaccines_link_title),
                action: interactor.didTapAboutApprovedVaccinesLink
            ),
            allApprovedDosesRadioButtonGroup.view,
            lastDoseDateQuestionHeading,
            lastDoseDateRadioButtonGroup.view,
            medicallyExemptMiddleQuestionHeading,
            medicallyExemptMiddleQuestionDescription,
            medicallyExemptMiddleRadioButtonGroup.view,
            clinicalTrialQuestionHeading,
            clinicalTrialRadioButtonGroup.view,
            medicallyExemptEndQuestionHeading,
            medicallyExemptEndQuestionDescription,
            medicallyExemptEndRadioButtonGroup.view,
        ])

        let contentStack = UIStackView(arrangedSubviews: stackedViews.flatMap { $0.content })
        contentStack.axis = .vertical
        contentStack.spacing = .standardSpacing

        let button = PrimaryButton(
            title: localize(.contact_case_vaccination_status_confirm_button_title),
            action: { [weak self] in
                guard let self = self else { return }
                let answers = ContactCaseVaccinationStatusAnswers(
                    fullyVaccinated: self.hasReceivedAllVaccineDosesSubject,
                    lastDose: self.isLastVaccineDoseTimeValid,
                    clinicalTrial: self.clinicalTrial,
                    medicallyExempt: self.medicallyExempt
                )
                let result = self.interactor.didTapConfirm(answers: answers)

                if case .failure = result {
                    self.emptyError.view.isHidden = false
                    self.scrollTo(self.emptyError.view)
                    UIAccessibility.post(notification: .layoutChanged, argument: self.emptyError)
                } else {
                    self.emptyError.view.isHidden(true)
                }
            }
        )

        let stackContent = [contentStack, button]
        let stackView = UIStackView(arrangedSubviews: stackContent)
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = .bigSpacing

        return [stackView]
    }

    private func nextQuestion() {
        let answers = ContactCaseVaccinationStatusAnswers(
            fullyVaccinated: hasReceivedAllVaccineDosesSubject,
            lastDose: isLastVaccineDoseTimeValid,
            clinicalTrial: clinicalTrial,
            medicallyExempt: medicallyExempt
        )
        let newQuestions = interactor.didAnswerQuestion(answers: answers)

        let shouldShowLastDose = newQuestions.contains(.lastDose)
        let shouldShowClinicalTrial = newQuestions.contains(.clinicalTrial)
        let shouldShowMedicallyExempt = newQuestions.contains(.medicallyExempt)

        setLastDoseVisibility(visible: shouldShowLastDose)
        setClinicalTrialVisibility(visible: shouldShowClinicalTrial)

        if shouldShowMedicallyExempt {
            if let lastQuestion = newQuestions.last, lastQuestion == .medicallyExempt, shouldShowClinicalTrial {
                setMedicallyExemptEndVisibility(visible: true)
                setMedicallyExemptMiddleVisibility(visible: false)
            } else {
                setMedicallyExemptEndVisibility(visible: false)
                setMedicallyExemptMiddleVisibility(visible: true)
            }
        } else {
            setMedicallyExemptEndVisibility(visible: false)
            setMedicallyExemptMiddleVisibility(visible: false)
        }

    }

    private func setLastDoseVisibility(visible: Bool) {
        if visible {
            lastDoseDateQuestionHeading.isHidden = false
            lastDoseDateRadioButtonGroup.view.isHidden = false
        } else {
            lastDoseDateQuestionHeading.isHidden = true
            lastDoseDateRadioButtonGroup.view.isHidden = true
        }
    }

    private func resetLastDose() {
        lastDoseDateRadioButtonGroup.rootView.state.selectedID = nil
        isLastVaccineDoseTimeValid = nil
    }

    private func setClinicalTrialVisibility(visible: Bool) {
        if visible {
            clinicalTrialQuestionHeading.isHidden = false
            clinicalTrialRadioButtonGroup.view.isHidden = false
        } else {
            clinicalTrialQuestionHeading.isHidden = true
            clinicalTrialRadioButtonGroup.view.isHidden = true
        }
    }

    private func resetClinicalTrial() {
        clinicalTrialRadioButtonGroup.rootView.state.selectedID = nil
        clinicalTrial = nil
    }

    private func setMedicallyExemptMiddleVisibility(visible: Bool) {
        if visible {
            medicallyExemptMiddleQuestionHeading.isHidden = false
            medicallyExemptMiddleQuestionDescription.isHidden = false
            medicallyExemptMiddleRadioButtonGroup.view.isHidden = false
        } else {
            medicallyExemptMiddleQuestionHeading.isHidden = true
            medicallyExemptMiddleQuestionDescription.isHidden = true
            medicallyExemptMiddleRadioButtonGroup.view.isHidden = true
        }
    }

    func resetMedicallyExemptMiddle() {
        medicallyExemptMiddleRadioButtonGroup.rootView.state.selectedID = nil
        medicallyExemptMiddle = nil
    }

    private func setMedicallyExemptEndVisibility(visible: Bool) {
        if visible {
            medicallyExemptEndQuestionHeading.isHidden = false
            medicallyExemptEndQuestionDescription.isHidden = false
            medicallyExemptEndRadioButtonGroup.view.isHidden = false
        } else {
            medicallyExemptEndQuestionHeading.isHidden = true
            medicallyExemptEndQuestionDescription.isHidden = true
            medicallyExemptEndRadioButtonGroup.view.isHidden = true
        }
    }

    func resetMedicallyExemptEnd() {
        medicallyExemptEndRadioButtonGroup.rootView.state.selectedID = nil
        medicallyExemptEnd = nil
    }

    private func makeRadioButtonView(
        yesTitle: String,
        yesAccessibility: String,
        yesAction: @escaping () -> Void,
        noTitle: String,
        noAccessibility: String,
        noAction: @escaping () -> Void
    ) -> UIHostingController<RadioButtonGroup> {
        let buttons = RadioButtonGroup(buttonViewModels: [
            RadioButtonGroup.ButtonViewModel(
                title: yesTitle,
                accessibilityText: yesAccessibility,
                action: { [weak self] in
                    yesAction()
                    self?.nextQuestion()
                }
            ),
            RadioButtonGroup.ButtonViewModel(
                title: noTitle,
                accessibilityText: noAccessibility,
                action: { [weak self] in
                    noAction()
                    self?.nextQuestion()
                }
            ),
        ])
        let vc = UIHostingController(rootView: buttons)
        vc.view.backgroundColor = .clear
        vc.view.isHidden = true
        return vc
    }

}

public class ContactCaseVaccinationStatusViewController: ScrollingContentViewController {
    public typealias Interacting = ContactCaseVaccinationStatusViewControllerInteracting

    private let content: ContactCaseVaccinationStatusContent

    public init(interactor: Interacting, vaccineThresholdDate: Date, isIndexCase: Bool) {
        let content = ContactCaseVaccinationStatusContent(
            interactor: interactor,
            vaccineThresholdDate: vaccineThresholdDate,
            isIndexCase: isIndexCase
        )
        self.content = content
        super.init(views: content.makeViews())
        content.scrollTo = scroll
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        title = localize(.contact_case_vaccination_status_title)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
