//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol ContactCaseContinueIsolationInteracting {
    func didTapBackToHome()
    func didTapCancel()
    func didTapGuidanceLink()
}

extension ContactCaseContinueIsolationViewController {
    private struct Content {
        let views: [StackViewContentProvider]
        
        init(interactor: Interacting, secondTestAdviceDate: Date?, isolationEndDate: Date) {
            let duration = LocalDay.today.daysRemaining(until: isolationEndDate)
            
            let pleaseIsolateStack =
                UIStackView(arrangedSubviews: [
                    BaseLabel()
                        .styleAsHeading()
                        .set(text: localize(.contact_case_continue_isolation_title))
                        .centralized(),
                    BaseLabel()
                        .styleAsPageHeader()
                        .set(text: localize(.contact_case_continue_isolation_days(days: duration)))
                        .centralized(),
                ])
            
            pleaseIsolateStack.accessibilityLabel = localize(.contact_case_continue_isolation_accessibility_label(days: duration))
            pleaseIsolateStack.axis = .vertical
            pleaseIsolateStack.isAccessibilityElement = true
            pleaseIsolateStack.accessibilityTraits = [.header, .staticText]
            
            var views: [StackViewContentProvider] = [
                UIImageView(.isolationStartContact)
                    .styleAsDecoration(),
                pleaseIsolateStack,
                InformationBox.indication.warning(localize(.contact_case_continue_isolation_info_box)),
            ]
            
            secondTestAdviceDate.map {
                views.append(contentsOf: [
                    WelcomePoint(image: .swabTest, body: localize(.contact_case_continue_isolation_list_item_testing_with_date(date: $0))),
                ])
            }
            
            views.append(contentsOf: [
                WelcomePoint(image: .isolation, body: localize(.contact_case_continue_isolation_list_item_isolation)),
                BaseLabel()
                    .styleAsBody()
                    .set(text: localize(.contact_case_continue_isolation_advice)),
                LinkButton(
                    title: localize(.contact_case_continue_isolation_link_title),
                    action: interactor.didTapGuidanceLink
                ),
                UIView(),
                PrimaryButton(
                    title: localize(.contact_case_continue_isolation_primary_button_title),
                    action: interactor.didTapBackToHome
                ),
            ])
            
            self.views = views
        }
    }
}

public class ContactCaseContinueIsolationViewController: ScrollingContentViewController {
    public typealias Interacting = ContactCaseContinueIsolationInteracting
    private let interactor: Interacting
    
    public init(interactor: Interacting, secondTestAdviceDate: Date?, isolationEndDate: Date) {
        self.interactor = interactor
        super.init(views: Content(interactor: interactor, secondTestAdviceDate: secondTestAdviceDate, isolationEndDate: isolationEndDate).views)
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
