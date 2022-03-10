//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol ContactCaseNoIsolationMedicallyExemptInteracting {
    func didTapBookAFreeTest()
    func didTapReadGuidanceForContacts()
    func didTapBackToHome()
    func didTapCancel()
    func didTapGuidanceLink()
    func didTapCommonQuestionsLink()
}

extension ContactCaseNoIsolationMedicallyExemptViewController {
    private struct Content {
        let views: [StackViewContentProvider]
        
        init(interactor: Interacting) {
            views = [
                UIImageView(.isolationStartIndex)
                    .styleAsDecoration(),
                BaseLabel()
                    .styleAsPageHeader()
                    .set(text: localize(.risky_contact_isolation_advice_medically_exempt))
                    .centralized(),
                InformationBox.indication.warning(localize(.risky_contact_isolation_advice_medically_exempt_info)),
                
                WelcomePoint(image: .socialDistancing, body: localize(.risky_contact_isolation_advice_medically_exempt_social_distancing_england)),
                WelcomePoint(image: .swabTest, body: localize(.risky_contact_isolation_advice_medically_exempt_get_tested_before_meeting_vulnerable_people_england)),
                WelcomePoint(image: .riskLevelFaceCoveringsIcon, body: localize(.risky_contact_isolation_advice_medically_exempt_wear_a_mask_england)),
                WelcomePoint(image: .riskLevelWorkIcon, body: localize(.risky_contact_isolation_advice_medically_exempt_work_from_home_england)),
                
                PrimaryLinkButton(
                    title: localize(.risky_contact_isolation_advice_medically_exempt_primary_button_title_read_guidance_england),
                    action: interactor.didTapReadGuidanceForContacts
                ),
                SecondaryButton(
                    title: localize(.risky_contact_isolation_advice_medically_exempt_secondary_button_title),
                    action: interactor.didTapBackToHome
                ),
            ]
        }
    }
}

public class ContactCaseNoIsolationMedicallyExemptViewController: ScrollingContentViewController {
    public typealias Interacting = ContactCaseNoIsolationMedicallyExemptInteracting
    private let interactor: Interacting
    
    public init(interactor: Interacting) {
        self.interactor = interactor
        super.init(views: Content(interactor: interactor).views)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: localize(.cancel),
            style: .done, target: self,
            action: #selector(didTapCancel)
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc func didTapCancel() {
        interactor.didTapCancel()
    }
}
