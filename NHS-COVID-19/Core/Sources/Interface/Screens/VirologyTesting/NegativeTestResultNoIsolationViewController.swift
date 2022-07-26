//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol NegativeTestResultNoIsolationViewControllerInteracting {
    func didTapOnlineServicesLink()
    func didTapReturnHome()
}

extension NegativeTestResultNoIsolationViewController {
    private class Content: PrimaryButtonStickyFooterScrollingContent {
        init(interactor: Interacting) {
            super.init(
                scrollingViews: [
                    UIImageView(.isolationEndedWarning).styleAsDecoration(),
                    BaseLabel().set(text: localizeForCountry (.negative_test_result_no_isolation_title)).styleAsPageHeader().centralized(),
                    BaseLabel().set(text: localizeForCountry(.negative_test_result_no_isolation_description)).styleAsHeading().centralized(),
                    InformationBox.indication.warning(localizeForCountry(.negative_test_result_no_isolation_warning)),
                    BaseLabel().set(text: localizeForCountry(.negative_test_result_no_isolation_link_hint)).styleAsSecondaryBody(),
                    LinkButton(
                        title: localizeForCountry(.nhs111_online_link_title),
                        action: interactor.didTapOnlineServicesLink
                    ),
                ],
                primaryButton: (
                    title: localize(.negative_test_result_no_isolation_button_label),
                    action: interactor.didTapReturnHome
                )
            )
        }
    }
}

public class NegativeTestResultNoIsolationViewController: StickyFooterScrollingContentViewController {

    public typealias Interacting = NegativeTestResultNoIsolationViewControllerInteracting

    public init(interactor: Interacting) {
        super.init(content: Content(interactor: interactor))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: animated)
    }
}
