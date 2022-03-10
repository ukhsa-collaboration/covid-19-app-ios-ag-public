//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol ContactCaseNoIsolationAdviceViewControllerInteracting {
    func didTapGuidanceForHouseholdContacts()
    func didTapReadGuidanceForContacts()
    func didTapBackToHome()
}

extension ContactCaseNoIsolationAdviceViewController {
    private struct Content {
        let views: [StackViewContentProvider]
        
        init(interactor: Interacting) {
            views = [
                UIImageView(.isolationEndedWarning)
                    .styleAsDecoration(),
                BaseLabel()
                    .styleAsPageHeader()
                    .set(text: localize(.risky_contact_opt_out_advice_title))
                    .centralized(),
                
                WelcomePoint(image: .riskLevelMeetingOutdoorsIcon, body: localize(.risky_contact_opt_out_advice_meeting_indoors)),
                WelcomePoint(image: .riskLevelFaceCoveringsIcon, body: localize(.risky_contact_opt_out_advice_mask)),
                WelcomePoint(image: .swabTest, body: localize(.risky_contact_opt_out_advice_testing_hub)),
                WelcomePoint(image: .washHands, body: localize(.risky_contact_opt_out_advice_wash_hands)),
                
                BaseLabel()
                    .styleAsBody()
                    .set(text: localize(.risky_contact_opt_out_further_advice)),
                LinkButton(
                    title: localize(.risky_contact_opt_out_further_advice_link_text),
                    action: interactor.didTapGuidanceForHouseholdContacts
                ),
                SpacerView(),
                PrimaryLinkButton(
                    title: localize(.risky_contact_opt_out_primary_button_title),
                    action: interactor.didTapReadGuidanceForContacts
                ),
                SecondaryButton(
                    title: localize(.risky_contact_opt_out_secondary_button_title),
                    action: interactor.didTapBackToHome
                ),
            ]
        }
    }
}

public class ContactCaseNoIsolationAdviceViewController: ScrollingContentViewController {
    public typealias Interacting = ContactCaseNoIsolationAdviceViewControllerInteracting
    private let interactor: Interacting
    
    public init(interactor: Interacting) {
        self.interactor = interactor
        super.init(views: Content(interactor: interactor).views)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationController?.navigationBar.styleAsTransparent()
    }
}
