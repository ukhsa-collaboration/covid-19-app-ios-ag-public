//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Localization
import UIKit

public protocol ContactCaseAcknowledgementViewControllerInteracting {
    func acknowledge()
    func didTapOnlineLink()
    func exposureFAQsLinkTapped()
    func didTapDailyContactTesting()
}

private class ContactCaseAcknowledgementContent: PrimaryButtonStickyFooterScrollingContent {
    public typealias Interacting = ContactCaseAcknowledgementViewControllerInteracting
    
    let interactor: Interacting
    let duration: Int
    
    public init(interactor: Interacting,
                isolationEndDate: Date,
                showDailyContactTesting: Bool) {
        self.interactor = interactor
        duration = LocalDay.today.daysRemaining(until: isolationEndDate)
        
        let pleaseIsolateStack =
            UIStackView(arrangedSubviews: [
                BaseLabel()
                    .styleAsHeading()
                    .set(text: localize(.exposure_acknowledgement_self_isolate_for))
                    .centralized(),
                BaseLabel()
                    .styleAsPageHeader()
                    .set(text: localize(.exposure_acknowledgement_days(days: duration)))
                    .centralized(),
            ])
        
        pleaseIsolateStack.accessibilityLabel = localize(.exposure_acknowledgement_please_isolate_accessibility_label(days: duration))
        pleaseIsolateStack.axis = .vertical
        pleaseIsolateStack.isAccessibilityElement = true
        pleaseIsolateStack.accessibilityTraits = [.header, .staticText]
        
        var viewStack: [StackViewContentProvider] = [
            UIImageView(.isolationStartContact)
                .styleAsDecoration(),
            pleaseIsolateStack,
            InformationBox.indication.warning(localize(.exposure_acknowledgement_warning)),
            localizeAndSplit(.exposure_acknowledgement_explaination)
                .map { BaseLabel().styleAsBody().set(text: String($0)) },
            LinkButton(
                title: localize(.exposure_faqs_link_button_title),
                action: interactor.exposureFAQsLinkTapped
            ),
            BaseLabel()
                .styleAsBody()
                .set(text: localize(.exposure_acknowledgement_link_label)),
            LinkButton(
                title: localize(.exposure_acknowledgement_link),
                action: interactor.didTapOnlineLink
            ),
        ]
        
        if showDailyContactTesting {
            viewStack.append(contentsOf: [
                BaseLabel()
                    .styleAsBody()
                    .set(text: localize(.exposure_acknowledgement_dct_blurb)),
                LinkButton(
                    title: localize(.exposure_acknowledgement_dct_link),
                    action: interactor.didTapDailyContactTesting
                ),
            ])
        }
        
        super.init(scrollingViews: viewStack, primaryButton: (
            title: localize(.exposure_acknowledgement_button),
            action: interactor.acknowledge
        ))
    }
    
}

public class ContactCaseAcknowledgementViewController: StickyFooterScrollingContentViewController {
    public typealias Interacting = ContactCaseAcknowledgementViewControllerInteracting
    
    public init(interactor: Interacting,
                isolationEndDate: Date,
                showDailyContactTesting: Bool) {
        super.init(
            content: ContactCaseAcknowledgementContent(
                interactor: interactor,
                isolationEndDate: isolationEndDate,
                showDailyContactTesting: showDailyContactTesting
            ))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}
