//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Localization
import SwiftUI
import UIKit

public protocol ContactCaseMultipleResolutionsFlowViewControllerInteracting {
    func nextVaccinationStatusQuestion(answers: ContactCaseVaccinationStatusAnswers) -> [ContactCaseVaccinationStatusQuestion]
    func didDeclareVaccinationStatus(answers: ContactCaseVaccinationStatusAnswers) -> Result<ContactCaseResolution, ContactCaseVaccinationStatusNotEnoughAnswersError>
    func didTapAboutApprovedVaccinesLink()
    func didReviewQuestions(overAgeLimit: Bool, vaccinationStatusAnswers: ContactCaseVaccinationStatusAnswers) -> Void
}

public struct ContactCaseResolution {
    let overAgeLimit: Bool
    let vaccinationStatusAnswers: [ContactCaseVaccinationStatusQuestionAndAnswer]
    
    public init(overAgeLimit: Bool, vaccinationStatusAnswers: [ContactCaseVaccinationStatusQuestionAndAnswer]) {
        self.overAgeLimit = overAgeLimit
        self.vaccinationStatusAnswers = vaccinationStatusAnswers
    }
}

public class ContactCaseMultipleResolutionsFlowViewController: BaseNavigationController {
    
    public typealias Interacting = ContactCaseMultipleResolutionsFlowViewControllerInteracting
    
    private enum State {
        case exposureInfo
        case ageDeclaration
        case vaccinationStatus
        case review(QuestionsAndAnswers)
    }
    
    private struct QuestionsAndAnswers: Equatable {
        let overAgeLimit: Bool
        let vaccinationStatusAnswers: [ContactCaseVaccinationStatusQuestionAndAnswer]
    }
    
    private let interactor: Interacting
    private let isIndexCase: Bool
    private let exposureDate: Date
    private let birthThresholdDate: Date
    private let vaccineThresholdDate: Date
    @Published private var state: State
    private var cancellables: Set<AnyCancellable> = []
    
    public init(interactor: Interacting,
                isIndexCase: Bool,
                exposureDate: Date,
                birthThresholdDate: Date,
                vaccineThresholdDate: Date) {
        self.interactor = interactor
        self.isIndexCase = isIndexCase
        self.exposureDate = exposureDate
        self.birthThresholdDate = birthThresholdDate
        self.vaccineThresholdDate = vaccineThresholdDate
        state = .exposureInfo
        super.init()
        monitorState()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func monitorState() {
        $state
            .regulate(as: .modelChange)
            .sink { [weak self] state in
                self?.update(for: state)
            }
            .store(in: &cancellables)
    }
    
    private func update(for state: State) {
        pushViewController(rootViewController(for: state), animated: true)
    }
    
    private func rootViewController(for state: State) -> UIViewController {
        switch state {
        case .exposureInfo:
            let interactor = ContactCaseExposureInfoInteractor(
                didTapContinue: { [weak self] in
                    self?.state = .ageDeclaration
                }
            )
            return ContactCaseExposureInfoViewController(
                interactor: interactor,
                exposureDate: exposureDate,
                isIndexCase: isIndexCase
            )
            
        case .ageDeclaration:
            let interactor = AgeDeclarationViewControllerInteractor(
                didTapContinue: { [weak self] isOverAgeLimit in
                    if isOverAgeLimit {
                        self?.state = .vaccinationStatus
                    } else {
                        let qA = QuestionsAndAnswers(overAgeLimit: isOverAgeLimit, vaccinationStatusAnswers: [])
                        self?.state = .review(qA)
                    }
                }
            )
            return AgeDeclarationViewController(
                interactor: interactor,
                birthThresholdDate: birthThresholdDate,
                isIndexCase: isIndexCase
            )
            
        case .vaccinationStatus:
            let interactor = VaccinationStatusViewControllerInteractor(
                didTapAboutApprovedVaccinesLink: { [weak self] in
                    self?.interactor.didTapAboutApprovedVaccinesLink()
                },
                didTapConfirm: { [weak self] answers in
                    guard let self = self else { return Result.failure(ContactCaseVaccinationStatusNotEnoughAnswersError()) }
                    let result = self.interactor.didDeclareVaccinationStatus(answers: answers)
                    
                    if case .success(let resolution) = result {
                        let qA = QuestionsAndAnswers(
                            overAgeLimit: resolution.overAgeLimit,
                            vaccinationStatusAnswers: resolution.vaccinationStatusAnswers
                        )
                        self.state = .review(qA)
                    }
                    return result.map { _ in
                        ()
                    }
                },
                didAnswerQuestion: { [weak self] answers in
                    guard let self = self else { return [] }
                    return self.interactor.nextVaccinationStatusQuestion(answers: answers)
                }
            )
            return ContactCaseVaccinationStatusViewController(
                interactor: interactor,
                vaccineThresholdDate: vaccineThresholdDate,
                isIndexCase: isIndexCase
            )
        case .review(let questionsAndAnswers):
            let interactor = ContactCaseSummaryViewControllerInteractor(
                didTapSubmitAnswerButton: { overAgeLimit, vaccinationStatusAnswers in
                    self.interactor.didReviewQuestions(
                        overAgeLimit: overAgeLimit,
                        vaccinationStatusAnswers: vaccinationStatusAnswers
                    )
                }, didTapChangeAgeButton: {
                    if questionsAndAnswers.overAgeLimit {
                        // Pop-back two viewcontrollers to be on the age screen
                        let viewControllers = self.viewControllers
                        self.popToViewController(viewControllers[viewControllers.count - 3], animated: true)
                    } else {
                        self.popViewController(animated: true)
                    }
                }, didTapChangeVaccinationStatusButton: {
                    self.popViewController(animated: true)
                }
            )
            
            return ContactCaseSummaryViewController(
                interactor: interactor,
                overAgeLimit: questionsAndAnswers.overAgeLimit,
                vaccinationStatusQuestionsAndAnswers: questionsAndAnswers.vaccinationStatusAnswers,
                birthThresholdDate: birthThresholdDate,
                vaccineThresholdDate: vaccineThresholdDate
            )
        }
    }
    
}

// MARK: - Interactors

private struct ContactCaseExposureInfoInteractor: ContactCaseExposureInfoViewController.Interacting {
    
    private let _didTapContinue: () -> Void
    
    init(didTapContinue: @escaping () -> Void) {
        _didTapContinue = didTapContinue
    }
    
    func didTapContinue() {
        _didTapContinue()
    }
    
}

private struct AgeDeclarationViewControllerInteractor: AgeDeclarationViewController.Interacting {
    
    private let _didTapContinue: (_ isOverAgeLimit: Bool) -> Void
    
    init(didTapContinue: @escaping (_ isOverAgeLimit: Bool) -> Void) {
        _didTapContinue = didTapContinue
    }
    
    func didTapContinueButton(_ isOverAgeLimit: Bool) {
        _didTapContinue(isOverAgeLimit)
    }
    
}

private struct VaccinationStatusViewControllerInteractor: ContactCaseVaccinationStatusViewController.Interacting {
    
    private let _didTapAboutApprovedVaccinesLink: () -> Void
    private let _didTapConfirm: (ContactCaseVaccinationStatusAnswers) -> Result<Void, ContactCaseVaccinationStatusNotEnoughAnswersError>
    private let _didAnswerQuestion: (ContactCaseVaccinationStatusAnswers) -> [ContactCaseVaccinationStatusQuestion]
    
    init(
        didTapAboutApprovedVaccinesLink: @escaping () -> Void,
        didTapConfirm: @escaping (ContactCaseVaccinationStatusAnswers) -> Result<Void, ContactCaseVaccinationStatusNotEnoughAnswersError>,
        didAnswerQuestion: @escaping (ContactCaseVaccinationStatusAnswers) -> [ContactCaseVaccinationStatusQuestion]
    ) {
        _didTapAboutApprovedVaccinesLink = didTapAboutApprovedVaccinesLink
        _didTapConfirm = didTapConfirm
        _didAnswerQuestion = didAnswerQuestion
    }
    
    func didTapAboutApprovedVaccinesLink() {
        _didTapAboutApprovedVaccinesLink()
    }
    
    func didTapConfirm(answers: ContactCaseVaccinationStatusAnswers) -> Result<Void, ContactCaseVaccinationStatusNotEnoughAnswersError> {
        _didTapConfirm(answers)
    }
    
    func didAnswerQuestion(answers: ContactCaseVaccinationStatusAnswers) -> [ContactCaseVaccinationStatusQuestion] {
        _didAnswerQuestion(answers)
    }
    
}

private struct ContactCaseSummaryViewControllerInteractor: ContactCaseSummaryViewController.Interacting {
    
    private let _didTapSubmitAnswersButton: (Bool, ContactCaseVaccinationStatusAnswers) -> Void
    private let _didTapChangeAgeButton: () -> Void
    private let _didTapChangeVaccinationStatusButton: () -> Void
    
    init(didTapSubmitAnswerButton: @escaping (Bool, ContactCaseVaccinationStatusAnswers) -> Void,
         didTapChangeAgeButton: @escaping () -> Void,
         didTapChangeVaccinationStatusButton: @escaping () -> Void) {
        _didTapSubmitAnswersButton = didTapSubmitAnswerButton
        _didTapChangeAgeButton = didTapChangeAgeButton
        _didTapChangeVaccinationStatusButton = didTapChangeVaccinationStatusButton
    }
    
    func didTapChangeAgeButton() {
        _didTapChangeAgeButton()
    }
    
    func didTapChangeVaccinationStatusButton() {
        _didTapChangeVaccinationStatusButton()
    }
    
    func didTapSubmitAnswersButton(overAgeLimit: Bool, vaccinationStatusAnswers: ContactCaseVaccinationStatusAnswers) {
        _didTapSubmitAnswersButton(overAgeLimit, vaccinationStatusAnswers)
    }
}
