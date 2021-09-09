//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Localization
import SwiftUI
import UIKit

public protocol ContactCaseStartIsolationInteracting {
    func didTapBookAFreeTest()
    func didTapBackToHome()
    func didTapCancel()
    func didTapGuidanceLink()
}

extension ContactCaseStartIsolationViewController {
    private struct Content {
        let views: [StackViewContentProvider]
        
        init(interactor: Interacting,
             isolationEndDate: Date,
             exposureDate: Date,
             isolationPeriod: DayDuration) {
            let duration = LocalDay.today.daysRemaining(until: isolationEndDate)
            let daysSinceExposure = -LocalDay.today.daysRemaining(until: exposureDate)
            
            let isolationPeriodInFullDays = isolationPeriod.days - 1
            
            let pleaseIsolateStack =
                UIStackView(arrangedSubviews: [
                    BaseLabel()
                        .styleAsHeading()
                        .set(text: localize(.contact_case_start_isolation_title))
                        .centralized(),
                    BaseLabel()
                        .styleAsPageHeader()
                        .set(text: localize(.contact_case_start_isolation_days(days: duration)))
                        .centralized(),
                ])
            
            pleaseIsolateStack.accessibilityLabel = localize(.contact_case_start_isolation_accessibility_label(days: duration))
            pleaseIsolateStack.axis = .vertical
            pleaseIsolateStack.isAccessibilityElement = true
            pleaseIsolateStack.accessibilityTraits = [.header, .staticText]
            
            views = [
                UIImageView(.isolationStartContact)
                    .styleAsDecoration(),
                pleaseIsolateStack,
                InformationBox.indication.warning(localize(.contact_case_start_isolation_info_box)),
                WelcomePoint(image: .swabTest, body: localize(.contact_case_start_isolation_list_item_lfd)),
                WelcomePoint(image: .isolation, body: localize(.contact_case_start_isolation_list_item_isolation)),
                BaseLabel()
                    .styleAsBody()
                    .set(text: localize(.contact_case_start_isolation_advice)),
                LinkButton(
                    title: localize(.contact_case_start_isolation_link_title),
                    action: interactor.didTapGuidanceLink
                ),
                PrimaryButton(
                    title: localize(.contact_case_start_isolation_primary_button_title),
                    action: interactor.didTapBookAFreeTest
                ),
                SecondaryButton(
                    title: localize(.contact_case_start_isolation_secondary_button_title),
                    action: interactor.didTapBackToHome
                ),
            ]
        }
    }
}

public class ContactCaseStartIsolationViewController: ScrollingContentViewController {
    public typealias Interacting = ContactCaseStartIsolationInteracting
    private let interactor: Interacting
    
    public init(interactor: Interacting,
                isolationEndDate: Date,
                exposureDate: Date,
                isolationPeriod: DayDuration) {
        self.interactor = interactor
        super.init(views: Content(
            interactor: interactor,
            isolationEndDate: isolationEndDate,
            exposureDate: exposureDate,
            isolationPeriod: isolationPeriod
        ).views)
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
