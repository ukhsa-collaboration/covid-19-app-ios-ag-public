//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol ContactCaseNoIsolationFullyVaccinatedInteracting {
    func didTapBookAFreeTest()
    func didTapBackToHome()
    func didTapCancel()
    func didTapGuidanceLink()
    func didTapCommonQuestionsLink()
}

extension ContactCaseNoIsolationFullyVaccinatedViewController {
    private struct Content {
        let views: [StackViewContentProvider]
        
        init(interactor: Interacting, secondTestAdviceDate: Date?) {
            var views: [StackViewContentProvider] = [
                UIImageView(.isolationStartIndex)
                    .styleAsDecoration(),
                BaseLabel()
                    .styleAsPageHeader()
                    .set(text: localize(.contact_case_no_isolation_fully_vaccinated_title))
                    .centralized(),
                InformationBox.indication.warning(localize(.contact_case_no_isolation_fully_vaccinated_info_box)),
                WelcomePoint(image: .infoCircle, body: localize(.contact_case_no_isolation_fully_vaccinated_list_item_info)),
                WelcomePoint(image: .socialDistancing, body: localize(.contact_case_no_isolation_fully_vaccinated_list_item_lfd)),
            ]
            
            secondTestAdviceDate.map {
                views.append(contentsOf: [
                    WelcomePoint(image: .swabTest, body: localize(.contact_case_no_isolation_fully_vaccinated_list_item_testing_with_date(date: $0))),
                ])
            }
            
            views.append(contentsOf: [
                LinkButton(
                    title: localize(.contact_case_no_isolation_fully_vaccinated_common_questions_button_title),
                    action: interactor.didTapCommonQuestionsLink
                ),
                BaseLabel()
                    .styleAsBody()
                    .set(text: localize(.contact_case_no_isolation_fully_vaccinated_advice)),
                LinkButton(
                    title: localize(.contact_case_no_isolation_fully_vaccinated_link_title),
                    action: interactor.didTapGuidanceLink
                ),
                PrimaryButton(
                    title: localize(.contact_case_no_isolation_fully_vaccinated_primary_button_title),
                    action: interactor.didTapBookAFreeTest
                ),
                SecondaryButton(
                    title: localize(.contact_case_no_isolation_fully_vaccinated_secondary_button_title),
                    action: interactor.didTapBackToHome
                ),
            ])
            
            self.views = views
        }
    }
}

public class ContactCaseNoIsolationFullyVaccinatedViewController: ScrollingContentViewController {
    public typealias Interacting = ContactCaseNoIsolationFullyVaccinatedInteracting
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
