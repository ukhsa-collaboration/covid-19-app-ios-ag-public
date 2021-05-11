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
                type: ContactCaseAcknowledgementViewController.ContactCaseType,
                showDailyContactTesting: Bool) {
        self.interactor = interactor
        duration = LocalDay.today.daysRemaining(until: isolationEndDate)
        
        let pleaseIsolateStack = type.pleaseIsolateStack(duration: duration)
        pleaseIsolateStack.accessibilityLabel = type.pleaseIsolateAccessibilityLabel(duration: duration)
        pleaseIsolateStack.axis = .vertical
        pleaseIsolateStack.isAccessibilityElement = true
        pleaseIsolateStack.accessibilityTraits = [.header, .staticText]
        
        var viewStack: [StackViewContentProvider] = [
            UIImageView(.isolationStartContact)
                .styleAsDecoration(),
            pleaseIsolateStack,
            InformationBox.indication.warning(type.warning),
            type.content,
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
    
    public enum ContactCaseType {
        case exposureDetection
        case riskyVenue
    }
    
    public init(interactor: Interacting,
                isolationEndDate: Date,
                type: ContactCaseType,
                showDailyContactTesting: Bool) {
        super.init(
            content: ContactCaseAcknowledgementContent(
                interactor: interactor,
                isolationEndDate: isolationEndDate,
                type: type,
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

extension ContactCaseAcknowledgementViewController.ContactCaseType {
    
    func pleaseIsolateStack(duration: Int) -> UIStackView {
        switch self {
        case .exposureDetection:
            return UIStackView(arrangedSubviews: [
                BaseLabel()
                    .styleAsHeading()
                    .set(text: localize(.exposure_acknowledgement_self_isolate_for))
                    .centralized(),
                BaseLabel()
                    .styleAsPageHeader()
                    .set(text: localize(.exposure_acknowledgement_days(days: duration)))
                    .centralized(),
            ])
        case .riskyVenue:
            return UIStackView(arrangedSubviews: [
                BaseLabel()
                    .styleAsHeading()
                    .set(text: localize(.exposure_acknowledgement_self_isolate_for))
                    .centralized(),
                BaseLabel()
                    .styleAsPageHeader()
                    .set(text: localize(.exposure_acknowledgement_days(days: duration)))
                    .centralized(),
                BaseLabel()
                    .styleAsHeading()
                    .set(text: localize(.risky_venue_isolation_report_symptoms))
                    .centralized(),
            ])
        }
    }
    
    func pleaseIsolateAccessibilityLabel(duration: Int) -> String {
        switch self {
        case .exposureDetection:
            return localize(.exposure_acknowledgement_please_isolate_accessibility_label(days: duration))
        case .riskyVenue:
            return localize(.risky_venue_isolation_title_accessibility(days: duration))
        }
    }
    
    var warning: String {
        switch self {
        case .exposureDetection:
            return localize(.exposure_acknowledgement_warning)
        case .riskyVenue:
            return localize(.risky_venue_isolation_warning)
        }
    }
    
    var content: [UIView] {
        switch self {
        case .exposureDetection:
            return localizeAndSplit(.exposure_acknowledgement_explaination)
                .map { BaseLabel().styleAsBody().set(text: String($0)) }
        case .riskyVenue:
            return localizeAndSplit(.risky_venue_isolation_description)
                .map { BaseLabel().styleAsBody().set(text: String($0)) }
        }
    }
}
