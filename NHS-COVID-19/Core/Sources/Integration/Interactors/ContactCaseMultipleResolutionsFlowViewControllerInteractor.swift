//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import Interface
import Localization

struct ContactCaseMultipleResolutionsFlowViewControllerInteractor: ContactCaseMultipleResolutionsFlowViewControllerInteracting {

    private let openURL: (URL) -> Void
    private let _didDeclareVaccinationStatus: (ContactCaseVaccinationStatusAnswers) -> Result<ContactCaseResolution, ContactCaseVaccinationStatusNotEnoughAnswersError>
    private let _nextVaccinationStatusQuestion: (ContactCaseVaccinationStatusAnswers) -> [ContactCaseVaccinationStatusQuestion]
    private let _didReviewQuestions: (Bool, ContactCaseVaccinationStatusAnswers) -> Void

    init(
        openURL: @escaping (URL) -> Void,
        didDeclareVaccinationStatus: @escaping (ContactCaseVaccinationStatusAnswers) -> Result<ContactCaseResolution, ContactCaseVaccinationStatusNotEnoughAnswersError>,
        nextVaccinationStatusQuestion: @escaping (ContactCaseVaccinationStatusAnswers) -> [ContactCaseVaccinationStatusQuestion],
        didReviewQuestions: @escaping (Bool, ContactCaseVaccinationStatusAnswers) -> Void
    ) {
        self.openURL = openURL
        _didDeclareVaccinationStatus = didDeclareVaccinationStatus
        _nextVaccinationStatusQuestion = nextVaccinationStatusQuestion
        _didReviewQuestions = didReviewQuestions
    }

    func didTapAboutApprovedVaccinesLink() {
        openURL(ExternalLink.approvedVaccinesInfo.url)
    }

    func nextVaccinationStatusQuestion(answers: ContactCaseVaccinationStatusAnswers) -> [ContactCaseVaccinationStatusQuestion] {
        _nextVaccinationStatusQuestion(answers)
    }

    func didDeclareVaccinationStatus(answers: ContactCaseVaccinationStatusAnswers) -> Result<ContactCaseResolution, ContactCaseVaccinationStatusNotEnoughAnswersError> {
        _didDeclareVaccinationStatus(answers)
    }

    func didReviewQuestions(overAgeLimit: Bool, vaccinationStatusAnswers: ContactCaseVaccinationStatusAnswers) {
        _didReviewQuestions(overAgeLimit, vaccinationStatusAnswers)
    }
}
