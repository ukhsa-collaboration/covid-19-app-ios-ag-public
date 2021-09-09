//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import Interface
import Localization

struct ContactCaseMultipleResolutionsFlowViewControllerInteractor: ContactCaseMultipleResolutionsFlowViewControllerInteracting {
    
    private let openURL: (URL) -> Void
    private let _didDeclareUnderAgeLimit: () -> Void
    private let _didDeclareVaccinationStatus: (_ fullyVaccinated: Bool?, _ lastDose: Bool?, _ clinicalTrial: Bool?, _ medicallyExempt: Bool?) -> Result<Void, ContactCaseVaccinationStatusNotEnoughAnswersError>
    private let _nextVaccinationStatusQuestion: (_ fullyVaccinated: Bool?, _ lastDose: Bool?, _ clinicalTrial: Bool?, _ medicallyExempt: Bool?) -> [ContactCaseVaccinationStatusQuestion]
    
    init(
        openURL: @escaping (URL) -> Void,
        didDeclareUnderAgeLimit: @escaping () -> Void,
        didDeclareVaccinationStatus: @escaping (_ fullyVaccinated: Bool?, _ lastDose: Bool?, _ clinicalTrial: Bool?, _ medicallyExempt: Bool?) -> Result<Void, ContactCaseVaccinationStatusNotEnoughAnswersError>,
        nextVaccinationStatusQuestion: @escaping (_ fullyVaccinated: Bool?, _ lastDose: Bool?, _ clinicalTrial: Bool?, _ medicallyExempt: Bool?) -> [ContactCaseVaccinationStatusQuestion]
    ) {
        self.openURL = openURL
        _didDeclareUnderAgeLimit = didDeclareUnderAgeLimit
        _didDeclareVaccinationStatus = didDeclareVaccinationStatus
        _nextVaccinationStatusQuestion = nextVaccinationStatusQuestion
    }
    
    func didTapAboutApprovedVaccinesLink() {
        openURL(ExternalLink.approvedVaccinesInfo.url)
    }
    
    func didDeclareUnderAgeLimit() {
        _didDeclareUnderAgeLimit()
    }
    
    func nextVaccinationStatusQuestion(fullyVaccinated: Bool?, lastDose: Bool?, clinicalTrial: Bool?, medicallyExempt: Bool?) -> [ContactCaseVaccinationStatusQuestion] {
        _nextVaccinationStatusQuestion(fullyVaccinated, lastDose, clinicalTrial, medicallyExempt)
    }
    
    func didDeclareVaccinationStatus(fullyVaccinated: Bool?, lastDose: Bool?, clinicalTrial: Bool?, medicallyExempt: Bool?) -> Result<Void, ContactCaseVaccinationStatusNotEnoughAnswersError> {
        _didDeclareVaccinationStatus(fullyVaccinated, lastDose, clinicalTrial, medicallyExempt)
    }
    
}
