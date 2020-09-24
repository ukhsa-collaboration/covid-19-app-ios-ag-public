//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Localization
import UIKit

public protocol ExposureAcknowledgementViewControllerInteracting {
    func acknowledge()
    func didTapOnlineLink()
}

private class ExposureAcknowledgementContent: PrimaryButtonStickyFooterScrollingContent {
    public typealias Interacting = ExposureAcknowledgementViewControllerInteracting
    
    let interactor: Interacting
    let duration: Int
    
    public init(interactor: Interacting, isolationEndDate: Date) {
        self.interactor = interactor
        duration = LocalDay.today.daysRemaining(until: isolationEndDate)
        
        let pleaseIsolateStack = UIStackView(arrangedSubviews: [
            UILabel()
                .styleAsHeading()
                .set(text: localize(.exposure_acknowledgement_self_isolate_for))
                .centralized(),
            UILabel()
                .styleAsPageHeader()
                .set(text: localize(.exposure_acknowledgement_days(days: duration)))
                .centralized(),
        ])
        
        pleaseIsolateStack.axis = .vertical
        pleaseIsolateStack.isAccessibilityElement = true
        pleaseIsolateStack.accessibilityTraits = [.staticText]
        pleaseIsolateStack.accessibilityLabel = localize(.exposure_acknowledgement_please_isolate_accessibility_label(days: duration))
        
        super.init(scrollingViews: [
            UIImageView(.isolationStartContact)
                .styleAsDecoration(),
            pleaseIsolateStack,
            InformationBox.indication.warning(localize(.exposure_acknowledgement_warning)),
            UILabel()
                .styleAsBody()
                .set(text: localize(.exposure_acknowledgement_explaination_1)),
            UILabel()
                .styleAsBody()
                .set(text: localize(.exposure_acknowledgement_explaination_2)),
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

public class ExposureAcknowledgementViewController: StickyFooterScrollingContentViewController {
    public typealias Interacting = ExposureAcknowledgementViewControllerInteracting
    
    public init(interactor: Interacting, isolationEndDate: Date) {
        super.init(content: ExposureAcknowledgementContent(interactor: interactor, isolationEndDate: isolationEndDate))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: false)
    }
}
