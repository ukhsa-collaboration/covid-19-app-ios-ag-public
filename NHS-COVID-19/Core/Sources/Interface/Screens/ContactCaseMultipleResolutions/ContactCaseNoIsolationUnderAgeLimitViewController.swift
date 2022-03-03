//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Localization
import UIKit

#warning("TODO: Should be separated into England and Wales variants as the screens have diverged significantly.")
public protocol ContactCaseNoIsolationUnderAgeLimitInteracting {
    func didTapBookAFreeTest()
    func didTapReadGuidanceForContacts()
    func didTapBackToHome()
    func didTapCancel()
    func didTapGuidanceLink()
    func didTapCommonQuestionsLink()
}

extension ContactCaseNoIsolationUnderAgeLimitEnglandViewController {
    private struct Content {
        let views: [StackViewContentProvider]
        
        init(interactor: Interacting) {
            var views: [StackViewContentProvider] = [
                UIImageView(.isolationStartIndex)
                    .styleAsDecoration(),
                BaseLabel()
                    .styleAsPageHeader()
                    .set(text: localize(.contact_case_no_isolation_under_age_limit_title))
                    .centralized(),
                InformationBox.indication.warning(localize(.contact_case_no_isolation_under_age_limit_info_box)),
            ]
            
            views.append(contentsOf: [
                WelcomePoint(image: .adultChild, body: localize(.contact_case_no_isolation_under_age_limit_list_item_adult)),
                WelcomePoint(image: .socialDistancing, body: localize(.contact_case_no_isolation_under_age_limit_list_item_social_distancing_england)),
                WelcomePoint(image: .swabTest, body: localize(.contact_case_no_isolation_under_age_limit_list_item_get_tested_before_meeting_vulnerable_people_england)),
                WelcomePoint(image: .riskLevelFaceCoveringsIcon, body: localize(.contact_case_no_isolation_under_age_limit_list_item_wear_a_mask_england)),
                PrimaryLinkButton(
                    title: localize(.contact_case_no_isolation_under_age_limit_primary_button_title_read_guidance_england),
                    action: interactor.didTapReadGuidanceForContacts
                ),
                SecondaryButton(
                    title: localize(.contact_case_no_isolation_under_age_limit_secondary_button_title),
                    action: interactor.didTapBackToHome
                ),
            ])
            
            self.views = views
        }
    }
}

public class ContactCaseNoIsolationUnderAgeLimitEnglandViewController: ScrollingContentViewController {
    public typealias Interacting = ContactCaseNoIsolationUnderAgeLimitInteracting
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

extension ContactCaseNoIsolationUnderAgeLimitWalesViewController {
    private struct Content {
        let views: [StackViewContentProvider]
        
        init(interactor: Interacting, secondTestAdviceDate: Date?) {
            var views: [StackViewContentProvider] = [
                UIImageView(.isolationStartIndex)
                    .styleAsDecoration(),
                BaseLabel()
                    .styleAsPageHeader()
                    .set(text: localize(.contact_case_no_isolation_under_age_limit_title_wales))
                    .centralized(),
                InformationBox.indication.warning(localize(.contact_case_no_isolation_under_age_limit_info_box_wales)),
            ]
            
            secondTestAdviceDate.map {
                views.append(contentsOf: [
                    WelcomePoint(image: .swabTest, body: localize(.contact_case_no_isolation_under_age_limit_list_item_testing_with_date(date: $0))),
                ])
            }
            
            views.append(contentsOf: [
                WelcomePoint(image: .socialDistancing, body: localize(.contact_case_no_isolation_under_age_limit_list_item_lfd_wales)),
                WelcomePoint(image: .adultChild, body: localize(.contact_case_no_isolation_under_age_limit_list_item_adult_wales)),
                LinkButton(
                    title: localize(.contact_case_no_isolation_under_age_limit_common_questions_button_title),
                    action: interactor.didTapCommonQuestionsLink
                ),
                BaseLabel()
                    .styleAsBody()
                    .set(text: localize(.contact_case_no_isolation_under_age_limit_advice)),
                LinkButton(
                    title: localize(.contact_case_no_isolation_under_age_limit_link_title),
                    action: interactor.didTapGuidanceLink
                ),
                PrimaryButton(
                    title: localize(.contact_case_no_isolation_under_age_limit_primary_button_title),
                    action: interactor.didTapBookAFreeTest
                ),
                SecondaryButton(
                    title: localize(.contact_case_no_isolation_under_age_limit_secondary_button_title),
                    action: interactor.didTapBackToHome
                ),
            ])
            
            self.views = views
        }
    }
}

public class ContactCaseNoIsolationUnderAgeLimitWalesViewController: ScrollingContentViewController {
    public typealias Interacting = ContactCaseNoIsolationUnderAgeLimitInteracting
    private let interactor: Interacting
    
    public init(interactor: Interacting, secondTestAdviceDate: Date?) {
        self.interactor = interactor
        super.init(views: Content(interactor: interactor, secondTestAdviceDate: secondTestAdviceDate).views)
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
