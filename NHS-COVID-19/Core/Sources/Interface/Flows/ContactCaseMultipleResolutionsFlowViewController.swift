//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Localization
import SwiftUI
import UIKit

public protocol ContactCaseMultipleResolutionsFlowViewControllerInteracting {
    func didDeclareUnderAgeLimit()
    func nextVaccinationStatusQuestion(
        fullyVaccinated: Bool?,
        lastDose: Bool?,
        clinicalTrial: Bool?,
        medicallyExempt: Bool?
    ) -> [ContactCaseVaccinationStatusQuestion]
    func didDeclareVaccinationStatus(
        fullyVaccinated: Bool?,
        lastDose: Bool?,
        clinicalTrial: Bool?,
        medicallyExempt: Bool?
    ) -> Result<Void, ContactCaseVaccinationStatusNotEnoughAnswersError>
    func didTapAboutApprovedVaccinesLink()
}

public class ContactCaseMultipleResolutionsFlowViewController: BaseNavigationController {
    
    public typealias Interacting = ContactCaseMultipleResolutionsFlowViewControllerInteracting
    
    private enum State: Equatable {
        case exposureInfo
        case ageDeclaration
        case vaccinationStatus
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
                        self?.interactor.didDeclareUnderAgeLimit()
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
                didTapConfirm: { [weak self] fullyVaccinated, lastDose, clinicalTrial, medicallyExempt in
                    guard let self = self else { return Result.failure(ContactCaseVaccinationStatusNotEnoughAnswersError()) }
                    return self.interactor.didDeclareVaccinationStatus(fullyVaccinated: fullyVaccinated, lastDose: lastDose, clinicalTrial: clinicalTrial, medicallyExempt: medicallyExempt)
                },
                didAnswerQuestion: { [weak self] fullyVaccinated, lastDose, clinicalTrial, medicallyExempt in
                    guard let self = self else { return [] }
                    return self.interactor.nextVaccinationStatusQuestion(fullyVaccinated: fullyVaccinated, lastDose: lastDose, clinicalTrial: clinicalTrial, medicallyExempt: medicallyExempt)
                }
            )
            return ContactCaseVaccinationStatusViewController(
                interactor: interactor,
                vaccineThresholdDate: vaccineThresholdDate,
                isIndexCase: isIndexCase
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
    private let _didTapConfirm: (_ fullyVaccinated: Bool?, _ lastDose: Bool?, _ clinicalTrial: Bool?, _ medicallyExempt: Bool?) -> Result<Void, ContactCaseVaccinationStatusNotEnoughAnswersError>
    private let _didAnswerQuestion: (_ fullyVaccinated: Bool?, _ lastDose: Bool?, _ clinicalTrial: Bool?, _ medicallyExempt: Bool?) -> [ContactCaseVaccinationStatusQuestion]
    
    init(
        didTapAboutApprovedVaccinesLink: @escaping () -> Void,
        didTapConfirm: @escaping (_ fullyVaccinated: Bool?, _ lastDose: Bool?, _ clinicalTrial: Bool?, _ medicallyExempt: Bool?) -> Result<Void, ContactCaseVaccinationStatusNotEnoughAnswersError>,
        didAnswerQuestion: @escaping (_ fullyVaccinated: Bool?, _ lastDose: Bool?, _ clinicalTrial: Bool?, _ medicallyExempt: Bool?) -> [ContactCaseVaccinationStatusQuestion]
    ) {
        _didTapAboutApprovedVaccinesLink = didTapAboutApprovedVaccinesLink
        _didTapConfirm = didTapConfirm
        _didAnswerQuestion = didAnswerQuestion
    }
    
    func didTapAboutApprovedVaccinesLink() {
        _didTapAboutApprovedVaccinesLink()
    }
    
    func didTapConfirm(fullyVaccinated: Bool?, lastDose: Bool?, clinicalTrial: Bool?, medicallyExempt: Bool?) -> Result<Void, ContactCaseVaccinationStatusNotEnoughAnswersError> {
        _didTapConfirm(fullyVaccinated, lastDose, clinicalTrial, medicallyExempt)
    }
    
    func didAnswerQuestion(fullyVaccinated: Bool?, lastDose: Bool?, clinicalTrial: Bool?, medicallyExempt: Bool?) -> [ContactCaseVaccinationStatusQuestion] {
        _didAnswerQuestion(fullyVaccinated, lastDose, clinicalTrial, medicallyExempt)
    }
    
}
