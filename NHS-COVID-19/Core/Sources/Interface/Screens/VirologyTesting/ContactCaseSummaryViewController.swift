//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Localization
import SwiftUI

public protocol ContactCaseSummaryViewControllerInteracting {
    func didTapChangeAgeButton()
    func didTapChangeVaccinationStatusButton()
    func didTapSubmitAnswersButton(overAgeLimit: Bool, vaccinationStatusAnswers: ContactCaseVaccinationStatusAnswers)
}

public struct ContactCaseVaccinationStatusQuestionAndAnswer: Equatable {
    let question: ContactCaseVaccinationStatusQuestion
    let answer: Bool
    
    public init(question: ContactCaseVaccinationStatusQuestion, answer: Bool) {
        self.question = question
        self.answer = answer
    }
}

class ContactCaseSummaryContent {
    public typealias Interacting = ContactCaseSummaryViewControllerInteracting
    typealias QuestionAndAnswer = ContactCaseSummaryViewController.QuestionAndAnswer
    
    private let interactor: Interacting
    private let overAgeLimit: Bool
    private let vaccinationStatusQuestionsAndAnswers: [ContactCaseVaccinationStatusQuestionAndAnswer]
    private let birthThresholdDate: Date
    private let vaccineThresholdDate: Date
    
    init(
        interactor: Interacting,
        overAgeLimit: Bool,
        vaccinationStatusQuestionsAndAnswers: [ContactCaseVaccinationStatusQuestionAndAnswer],
        birthThresholdDate: Date,
        vaccineThresholdDate: Date
    ) {
        self.interactor = interactor
        self.overAgeLimit = overAgeLimit
        self.vaccinationStatusQuestionsAndAnswers = vaccinationStatusQuestionsAndAnswers
        self.birthThresholdDate = birthThresholdDate
        self.vaccineThresholdDate = vaccineThresholdDate
    }
    
    private func makeAnsweredVaccineStatusQuestion(_ question: ContactCaseVaccinationStatusQuestion, answer: Bool) -> QuestionAndAnswer {
        
        switch question {
        case .fullyVaccinated:
            return QuestionAndAnswer(
                question: localize(.contact_case_vaccination_status_all_doses_of_vaccine_question),
                answer: answer,
                answerContent: answer == true ? localize(.contact_case_vaccination_status_all_doses_of_vaccine_yes_option) :
                    localize(.contact_case_vaccination_status_all_doses_of_vaccine_no_option),
                answerAccessibilityText: answer == true ? localize(.contact_case_vaccination_status_all_doses_of_vaccine_yes_option_accessibility_text) : localize(.contact_case_vaccination_status_all_doses_of_vaccine_no_option_accessibility_text)
            )
        case .lastDose:
            return QuestionAndAnswer(
                question: localize(.contact_case_vaccination_status_last_dose_of_vaccine_question(date: vaccineThresholdDate)),
                answer: answer,
                answerContent: answer == true ? localize(.contact_case_vaccination_status_last_dose_of_vaccine_yes_option) :
                    localize(.contact_case_vaccination_status_last_dose_of_vaccine_no_option),
                answerAccessibilityText: answer == true ?
                    localize(.contact_case_vaccination_status_last_dose_of_vaccine_yes_option_accessibility_text(date: vaccineThresholdDate)) :
                    localize(.contact_case_vaccination_status_last_dose_of_vaccine_no_option_accessibility_text(date: vaccineThresholdDate))
            )
        case .clinicalTrial:
            return QuestionAndAnswer(
                question: localize(.exposure_notification_clinical_trial_question),
                answer: answer,
                answerContent: answer == true ? localize(.exposure_notification_clinical_trial_yes) :
                    localize(.exposure_notification_clinical_trial_no),
                answerAccessibilityText: answer == true ?
                    localize(.exposure_notification_clinical_trial_yes_content_description) :
                    localize(.exposure_notification_clinical_trial_no_content_description)
            )
        case .medicallyExempt:
            return QuestionAndAnswer(
                question: localize(.exposure_notification_medically_exempt_question),
                answer: answer,
                answerContent: answer == true ? localize(.exposure_notification_medically_exempt_yes) : localize(.exposure_notification_medically_exempt_no),
                answerAccessibilityText: answer == true ? localize(.exposure_notification_medically_exempt_yes_content_description) : localize(.exposure_notification_medically_exempt_no_content_description)
            )
        }
    }
    
    private func makeVaccinationStatusBox() -> UIView? {
        var answeredQuestions: [QuestionAndAnswer] = []
        
        for qa in vaccinationStatusQuestionsAndAnswers {
            answeredQuestions.append(makeAnsweredVaccineStatusQuestion(qa.question, answer: qa.answer))
        }
        
        guard !answeredQuestions.isEmpty else { return nil }
        
        let vaccinationStatusAnswerBoxViewModel = AnswerBox.ViewModel(
            headerText: localize(.contact_case_vaccination_status_heading),
            buttonTitle: (text: localize(.contact_case_summary_change_vaccination_status_button), accessibilityText: localize(.contact_case_summary_change_vaccination_status_accessiblity_button)),
            buttonAction: interactor.didTapChangeVaccinationStatusButton, questionsWithAnswers: answeredQuestions
        )
        
        let vaccinationStatusAnswerBox = AnswerBox(viewModel: vaccinationStatusAnswerBoxViewModel)
        let vaccineStatusHostingVC = UIHostingController(rootView: vaccinationStatusAnswerBox)
        vaccineStatusHostingVC.view.backgroundColor = .clear
        
        return vaccineStatusHostingVC.view
    }
    
    private func makeAgeAnswerBox() -> UIView {
        
        let ageQuestionAndAnswer = QuestionAndAnswer(
            question: localize(.age_declaration_question(date: birthThresholdDate)),
            answer: overAgeLimit,
            answerContent: overAgeLimit ? localize(.age_declaration_yes_option) : localize(.age_declaration_no_option),
            answerAccessibilityText: overAgeLimit ? localize(.age_declaration_yes_option_accessibility_text(date: birthThresholdDate)) : localize(.age_declaration_no_option_accessibility_text(date: birthThresholdDate))
        )
        
        let ageAnswerBoxViewModel = AnswerBox.ViewModel(
            headerText: localize(.age_declaration_heading),
            buttonTitle: (text: localize(.contact_case_summary_change_age_button), accessibilityText: localize(.contact_case_summary_change_age_accessiblity_button)),
            buttonAction: interactor.didTapChangeAgeButton,
            questionsWithAnswers: [ageQuestionAndAnswer]
        )
        
        let ageAnswerBox = AnswerBox(viewModel: ageAnswerBoxViewModel)
        let hostingVC = UIHostingController(rootView: ageAnswerBox)
        hostingVC.view.backgroundColor = .clear
        
        return hostingVC.view!
    }
    
    private func confirmAnswers() {
        var fullyVaccinated: Bool?
        var lastDose: Bool?
        var clinicalTrial: Bool?
        var medicallyExempt: Bool?
        
        for qa in vaccinationStatusQuestionsAndAnswers {
            switch qa.question {
            case .fullyVaccinated:
                fullyVaccinated = qa.answer
            case .lastDose:
                lastDose = qa.answer
            case .clinicalTrial:
                clinicalTrial = qa.answer
            case .medicallyExempt:
                medicallyExempt = qa.answer
            }
        }
        
        let answers = ContactCaseVaccinationStatusAnswers(
            fullyVaccinated: fullyVaccinated,
            lastDose: lastDose,
            clinicalTrial: clinicalTrial,
            medicallyExempt: medicallyExempt
        )
        interactor.didTapSubmitAnswersButton(overAgeLimit: overAgeLimit, vaccinationStatusAnswers: answers)
    }
    
    func makeViews() -> [StackViewContentProvider] {
        let primaryButton = PrimaryButton(title: localize(.contact_case_summary_submit_button), action: confirmAnswers)
        let heading = BaseLabel().set(text: localize(.contact_case_summary_heading)).styleAsPageHeader()
        return [heading, makeAgeAnswerBox(), makeVaccinationStatusBox(), UIView(), primaryButton].compactMap { $0 }
    }
}

public class ContactCaseSummaryViewController:
    ScrollingContentViewController {
    public typealias Interacting = ContactCaseSummaryViewControllerInteracting
    
    public struct QuestionAndAnswer {
        let question: String
        let answer: Bool
        let answerContent: String
        let answerAccessibilityText: String
        
        public init(
            question: String,
            answer: Bool,
            answerContent: String,
            answerAccessibilityText: String
        ) {
            self.question = question
            self.answer = answer
            self.answerContent = answerContent
            self.answerAccessibilityText = answerAccessibilityText
        }
    }
    
    public init(
        interactor: Interacting,
        overAgeLimit: Bool,
        vaccinationStatusQuestionsAndAnswers: [ContactCaseVaccinationStatusQuestionAndAnswer],
        birthThresholdDate: Date,
        vaccineThresholdDate: Date
    ) {
        let content = ContactCaseSummaryContent(
            interactor: interactor,
            overAgeLimit: overAgeLimit,
            vaccinationStatusQuestionsAndAnswers: vaccinationStatusQuestionsAndAnswers,
            birthThresholdDate: birthThresholdDate,
            vaccineThresholdDate: vaccineThresholdDate
        )
        
        super.init(views: content.makeViews())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        title = localize(.contact_case_summary_title)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}

private struct AnswerBox: View {
    typealias QuestionAndAnswer = ContactCaseSummaryViewController.QuestionAndAnswer
    
    struct ViewModel {
        let headerText: String
        let buttonTitle: (text: String, accessibilityText: String)
        let buttonAction: () -> Void
        let questionsWithAnswers: [QuestionAndAnswer]
    }
    
    private let viewModel: ViewModel
    
    init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        Box {
            // Header
            HStack {
                Text(viewModel.headerText)
                    .styleAsHeading()
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
                Button.underlined(text: viewModel.buttonTitle.text, action: viewModel.buttonAction)
                    .accessibility(label: Text(viewModel.buttonTitle.accessibilityText))
                    .fixedSize(horizontal: false, vertical: true)
                
            }
            
            ForEach(viewModel.questionsWithAnswers, id: \.question) { qAndA in
                Divider()
                Text(qAndA.question)
                    .styleAsHeading()
                    .fixedSize(horizontal: false, vertical: true)
                
                HStack {
                    Image(qAndA.answer == true ? .checkIcon : .crossIcon)
                        .accessibility(hidden: true)
                    
                    Text(qAndA.answerContent)
                        .styleAsBody()
                        .accessibility(label: Text(qAndA.answerAccessibilityText))
                }
            }
            
        }
    }
}
