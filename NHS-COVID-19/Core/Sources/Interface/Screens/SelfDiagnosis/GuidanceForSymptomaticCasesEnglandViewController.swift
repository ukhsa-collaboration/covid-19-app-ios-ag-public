//
// Copyright © 2022 DHSC. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol GuidanceForSymptomaticCasesEnglandViewControllerInteracting {
    func didTapCommonQuestionsLink()
    func didTapNHSOnlineLink()
    func didTapBackToHome()
}

extension GuidanceForSymptomaticCasesEnglandViewController {
    private struct Content {
        let views: [StackViewContentProvider]
        
        init(interactor: Interacting) {
            views = [
                UIImageView(.isolationEndedWarning)
                    .styleAsDecoration(),
                BaseLabel()
                    .styleAsPageHeader()
                    .set(text: localize(.symptomatic_contact_guidance_title_england))
                    .centralized(),
                
                WelcomePoint(image: .riskLevelFaceCoveringsIcon, body: localize(.symptomatic_contact_guidance_mask_england)),
                WelcomePoint(image: .riskLevelSocialDistancingIcon, body: localize(.symptomatic_contact_guidance_testing_hub_england)),
                WelcomePoint(image: .riskLevelMeetingOutdoorsIcon, body: localize(.symptomatic_contact_guidance_meeting_indoors_england)),
                WelcomePoint(image: .washHands, body: localize(.symptomatic_contact_guidance_wash_hands_england)),
                
                LinkButton(
                    title: localize(.symptomatic_contact_guidance_common_questions_link_england),
                    action: interactor.didTapCommonQuestionsLink
                ),
                BaseLabel()
                    .styleAsBody()
                    .set(text: localize(.symptomatic_contact_guidance_further_advice_england)),
                LinkButton(
                    title: localize(.symptomatic_contact_guidance_nhs_online_link_england),
                    action: interactor.didTapNHSOnlineLink
                ),
                
                SpacerView(),
                PrimaryButton(
                    title: localize(.symptomatic_contact_primary_button_title_england),
                    action: interactor.didTapBackToHome
                ),
            ]
        }
        
    }
}

public class GuidanceForSymptomaticCasesEnglandViewController: ScrollingContentViewController {
    public typealias Interacting = GuidanceForSymptomaticCasesEnglandViewControllerInteracting
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
