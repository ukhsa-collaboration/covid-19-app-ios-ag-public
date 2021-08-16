//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import Interface
import Localization

struct ContactCaseMultipleResolutionsFlowViewControllerInteractor: ContactCaseMultipleResolutionsFlowViewControllerInteracting {
    
    private let openURL: (URL) -> Void
    private let _didDeclareUnderAgeLimit: () -> Void
    private let _didDeclareVaccinationStatus: (_ isFullyVaccinated: Bool) -> Void
    
    init(
        openURL: @escaping (URL) -> Void,
        didDeclareUnderAgeLimit: @escaping () -> Void,
        didDeclareVaccinationStatus: @escaping (_ isFullyVaccinated: Bool) -> Void
    ) {
        self.openURL = openURL
        _didDeclareUnderAgeLimit = didDeclareUnderAgeLimit
        _didDeclareVaccinationStatus = didDeclareVaccinationStatus
    }
    
    func didTapAboutApprovedVaccinesLink() {
        openURL(ExternalLink.approvedVaccinesInfo.url)
    }
    
    func didDeclareUnderAgeLimit() {
        _didDeclareUnderAgeLimit()
    }
    
    func didDeclareVaccinationStatus(isFullyVaccinated: Bool) {
        _didDeclareVaccinationStatus(isFullyVaccinated)
    }
    
}
