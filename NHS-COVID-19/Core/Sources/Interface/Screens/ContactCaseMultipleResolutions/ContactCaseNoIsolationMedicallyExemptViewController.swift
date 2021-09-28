//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol ContactCaseNoIsolationMedicallyExemptInteracting {
    func didTapBookAFreeTest()
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
                WelcomePoint(image: .info, body: localize(.risky_contact_isolation_advice_medically_exempt_research)),
                WelcomePoint(image: .groupOfPeople, body: localize(.risky_contact_isolation_advice_medically_exempt_group)),
                WelcomePoint(image: .socialDistancing, body: localize(.risky_contact_isolation_advice_medically_exempt_advice)),
                LinkButton(
                    title: localize(.risky_contact_isolation_advice_medically_exempt_common_questions_link_title),
                    action: interactor.didTapCommonQuestionsLink
                ),
                BaseLabel()
                    .set(text: localize(.risky_contact_isolation_advice_medically_exempt_nhs_guidance_link_preamble)),
                LinkButton(
                    title: localize(.risky_contact_isolation_advice_medically_exempt_nhs_guidance_link_title),
                    action: interactor.didTapGuidanceLink
                ),
                
                PrimaryButton(
                    title: localize(.risky_contact_isolation_advice_medically_exempt_primary_button_title),
                    action: interactor.didTapBookAFreeTest
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
