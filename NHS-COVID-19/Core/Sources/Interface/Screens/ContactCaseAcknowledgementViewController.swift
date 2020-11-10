//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Localization
import UIKit

public protocol ContactCaseAcknowledgementViewControllerInteracting {
    func acknowledge()
    func didTapOnlineLink()
    func exposureFAQsLinkTapped()
}

private class ContactCaseAcknowledgementContent: PrimaryButtonStickyFooterScrollingContent {
    public typealias Interacting = ContactCaseAcknowledgementViewControllerInteracting
    
    let interactor: Interacting
    let duration: Int
    
    public init(interactor: Interacting, isolationEndDate: Date, type: ContactCaseAcknowledgementViewController.ContactCaseType) {
        self.interactor = interactor
        duration = LocalDay.today.daysRemaining(until: isolationEndDate)
        
        let pleaseIsolateStack = type.pleaseIsolateStack(duration: duration)
        pleaseIsolateStack.accessibilityLabel = type.pleaseIsolateAccessibilityLabel(duration: duration)
        pleaseIsolateStack.axis = .vertical
        pleaseIsolateStack.isAccessibilityElement = true
        pleaseIsolateStack.accessibilityTraits = [.header, .staticText]
        
        super.init(scrollingViews: [
            UIImageView(.isolationStartContact)
                .styleAsDecoration(),
            pleaseIsolateStack,
            InformationBox.indication.warning(type.warning),
            type.content,
            UILabel().set(text: localize(.exposure_faqs_link_label)).styleAsBody(),
            LinkButton(
                title: localize(.exposure_faqs_link_button_title),
                action: interactor.exposureFAQsLinkTapped
            ),
            UILabel()
                .styleAsBody()
                .set(text: localize(.exposure_acknowledgement_link_label)),
            LinkButton(
                title: localize(.exposure_acknowledgement_link),
                action: interactor.didTapOnlineLink
            ),
        ], primaryButton: (
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
    
    public init(interactor: Interacting, isolationEndDate: Date, type: ContactCaseType) {
        super.init(content: ContactCaseAcknowledgementContent(interactor: interactor, isolationEndDate: isolationEndDate, type: type))
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
                UILabel()
                    .styleAsHeading()
                    .set(text: localize(.exposure_acknowledgement_self_isolate_for))
                    .centralized(),
                UILabel()
                    .styleAsPageHeader()
                    .set(text: localize(.exposure_acknowledgement_days(days: duration)))
                    .centralized(),
            ])
        case .riskyVenue:
            return UIStackView(arrangedSubviews: [
                UILabel()
                    .styleAsHeading()
                    .set(text: localize(.exposure_acknowledgement_self_isolate_for))
                    .centralized(),
                UILabel()
                    .styleAsPageHeader()
                    .set(text: localize(.exposure_acknowledgement_days(days: duration)))
                    .centralized(),
                UILabel()
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
            return [
                UILabel()
                    .styleAsBody()
                    .set(text: localize(.exposure_acknowledgement_explaination_1)),
                UILabel()
                    .styleAsBody()
                    .set(text: localize(.exposure_acknowledgement_explaination_2)),
            ]
        case .riskyVenue:
            return localizeAndSplit(.risky_venue_isolation_description)
                .map { UILabel().styleAsBody().set(text: String($0)) }
        }
    }
}
