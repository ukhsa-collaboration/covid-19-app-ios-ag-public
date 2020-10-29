//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import UIKit

public protocol PrivacyViewControllerInteracting {
    func didTapPrivacyNotice()
    
    func didTapTermsOfUse()
    
    func didTapAgree()
    
    func didTapNoThanks()
}

public class PrivacyViewController: ScrollingContentViewController {
    public typealias Interacting = PrivacyViewControllerInteracting
    
    public init(interactor: Interacting) {
        super.init(
            views: [
                LogoStrapline(.nhsBlue, style: .onboarding),
                UIImageView(.onboardingPrivacy).styleAsDecoration(),
                UILabel().styleAsPageHeader().set(text: localize(.privacy_title)),
                UILabel().styleAsTertiaryTitle().set(text: localize(.privacy_header)),
                localizeAndSplit(.privacy_description_paragraph1).map {
                    UILabel().styleAsBody().set(text: $0)
                },
                UILabel().styleAsTertiaryTitle().set(text: localize(.data_header)),
                UILabel().styleAsBody().set(text: localize(.privacy_description_paragraph2)),
                UILabel().styleAsBody().set(text: localize(.privacy_description_paragraph4)),
                UILabel().styleAsHeading().set(text: localize(.privacy_links_label))
                    .accessibilityLabel(localize(.privacy_links_accessibility_label)),
                LinkButton(
                    title: localize(.privacy_notice_label),
                    action: interactor.didTapPrivacyNotice
                ),
                LinkButton(
                    title: localize(.terms_of_use_label),
                    action: interactor.didTapTermsOfUse
                ),
                PrimaryButton(
                    title: localize(.privacy_yes_button),
                    action: interactor.didTapAgree
                ),
                SecondaryButton(
                    title: localize(.privacy_no_button),
                    action: interactor.didTapNoThanks
                ).accessibilityLabel(localize(.privacy_no_button_accessibility_label)),
            ]
        )
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
