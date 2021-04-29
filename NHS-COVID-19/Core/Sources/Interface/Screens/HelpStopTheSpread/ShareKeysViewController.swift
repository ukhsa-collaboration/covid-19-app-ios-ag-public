//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol ShareKeysViewControllerInteracting {
    var didTapContinue: () -> Void { get }
}

extension ShareKeysViewController {
    private class Content: PrimaryButtonStickyFooterScrollingContent {
        init(interactor: Interacting) {
            super.init(
                scrollingViews: [
                    UIImageView(.shareKeys).styleAsDecoration(),
                    BaseLabel().set(text: localize(.share_keys_and_venues_share_keys_heading)).styleAsPageHeader(),
                    IconAndTextBoxView.privacy(text: localize(.share_keys_and_venues_share_keys_privacy_notice)),
                    BaseLabel().set(text: localize(.share_keys_and_venues_share_keys_how_it_helps_heading)).styleAsHeading(),
                    BaseLabel().set(text: localize(.share_keys_and_venues_share_keys_how_it_helps_body)).styleAsBody(),
                    BaseLabel().set(text: localize(.share_keys_and_venues_share_keys_what_is_a_random_id_heading)).styleAsHeading(),
                    BaseLabel().set(text: localize(.share_keys_and_venues_share_keys_what_is_a_random_id_body)).styleAsBody(),
                ],
                primaryButton: (
                    title: localize(.share_keys_and_venues_share_keys_button),
                    action: interactor.didTapContinue
                )
            )
        }
    }
}

public class ShareKeysViewController: StickyFooterScrollingContentViewController {
    
    public typealias Interacting = ShareKeysViewControllerInteracting
    let interactor: Interacting
    
    public init(interactor: Interacting) {
        self.interactor = interactor
        super.init(content: Content(interactor: interactor))
        title = localize(.share_keys_and_venues_share_keys_title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
