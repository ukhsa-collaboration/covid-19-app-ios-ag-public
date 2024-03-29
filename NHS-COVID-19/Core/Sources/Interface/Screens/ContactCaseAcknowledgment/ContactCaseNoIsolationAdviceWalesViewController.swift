//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol ContactCaseNoIsolationAdviceWalesViewControllerInteracting {
    func didTapReadGuidanceForContacts()
    func didTapBackToHome()
}

extension ContactCaseNoIsolationAdviceWalesViewController {
    private struct Content {
        let views: [StackViewContentProvider]

        init(interactor: Interacting) {
            views = [
                UIImageView(.isolationEndedWarning)
                    .styleAsDecoration(),
                BaseLabel()
                    .styleAsPageHeader()
                    .set(text: localize(.risky_contact_opt_out_advice_title_wales))
                    .centralized(),

                WelcomePoint(image: .riskLevelMeetingOutdoorsIcon, body: localize(.risky_contact_opt_out_advice_meeting_indoors_wales)),
                WelcomePoint(image: .riskLevelFaceCoveringsIcon, body: localize(.risky_contact_opt_out_advice_mask_wales)),
                WelcomePoint(image: .infoCircle, body: localize(.risky_contact_opt_out_advice_testing_hub_wales)),
                WelcomePoint(image: .washHands, body: localize(.risky_contact_opt_out_advice_wash_hands_wales)),
                SpacerView(),
                PrimaryLinkButton(
                    title: localize(.risky_contact_opt_out_primary_button_title_wales),
                    action: interactor.didTapReadGuidanceForContacts
                ),
                SecondaryButton(
                    title: localize(.risky_contact_opt_out_secondary_button_title_wales),
                    action: interactor.didTapBackToHome
                ),
            ]
        }
    }
}

public class ContactCaseNoIsolationAdviceWalesViewController: ScrollingContentViewController {
    public typealias Interacting = ContactCaseNoIsolationAdviceWalesViewControllerInteracting
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
