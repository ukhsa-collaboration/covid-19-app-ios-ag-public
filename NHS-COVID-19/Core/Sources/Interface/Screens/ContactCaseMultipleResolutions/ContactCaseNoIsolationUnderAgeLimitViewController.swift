//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol ContactCaseNoIsolationUnderAgeLimitInteracting {
    func didTapBookAFreeTest()
    func didTapBackToHome()
    func didTapCancel()
    func didTapGuidanceLink()
    func didTapCommonQuestionsLink()
}

extension ContactCaseNoIsolationUnderAgeLimitViewController {
    private struct Content {
        let views: [StackViewContentProvider]
        
        init(interactor: Interacting) {
            views = [
                UIImageView(.isolationStartIndex)
                    .styleAsDecoration(),
                BaseLabel()
                    .styleAsPageHeader()
                    .set(text: localize(.contact_case_no_isolation_under_age_limit_title))
                    .centralized(),
                InformationBox.indication.warning(localize(.contact_case_no_isolation_under_age_limit_info_box)),
                WelcomePoint(image: .swabTest, body: localize(.contact_case_no_isolation_under_age_limit_list_item_lfd)),
                WelcomePoint(image: .adultChild, body: localize(.contact_case_no_isolation_under_age_limit_list_item_adult)),
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
            ]
        }
    }
}

public class ContactCaseNoIsolationUnderAgeLimitViewController: ScrollingContentViewController {
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
