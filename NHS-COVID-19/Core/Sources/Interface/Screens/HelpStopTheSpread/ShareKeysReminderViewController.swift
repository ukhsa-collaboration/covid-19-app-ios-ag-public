//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol ShareKeysReminderViewControllerInteracting {
    var didTapShareResult: () -> Void { get }
    var didTapDoNotShareResult: () -> Void { get }
}

extension ShareKeysReminderViewController {

    private class Content: StickyFooterScrollingContent {

        static let infoboxInset = (.stripeWidth + .stripeSpacing)

        let scrollingContent: StackContent
        let footerContent: StackContent?
        let spacing: CGFloat = .doubleSpacing

        init(interactor: Interacting) {
            scrollingContent = BasicContent(
                views: [
                    UIStackView(content: BasicContent(
                        views: [
                            UIImageView(.shareKeysReview).styleAsDecoration(),
                            BaseLabel().styleAsPageHeader().set(text: localize(.share_keys_and_venues_reminder_screen_heading)),
                            IconAndTextBoxView.privacy(text: localize(.share_keys_and_venues_reminder_screen_privacy_notice)),
                            BaseLabel().styleAsHeading().set(text: localize(.share_keys_and_venues_reminder_screen_reconsider_sharing_heading)),
                            BaseLabel().styleAsBody().set(text: localize(.share_keys_and_venues_reminder_screen_reconsider_sharing_body)),
                        ],
                        spacing: .standardSpacing,
                        margins: mutating(.zero) {
                            $0.left = Self.infoboxInset
                            $0.right = Self.infoboxInset
                        }
                    )),
                ],
                spacing: .standardSpacing,
                margins: mutating(.largeInset) {
                    $0.bottom = 0
                    $0.left -= Self.infoboxInset
                    $0.right -= Self.infoboxInset
                }
            )

            footerContent = BasicContent(
                views: [
                    PrimaryButton(title: localize(.share_keys_and_venues_reminder_screen_back_to_share_button_title), action: interactor.didTapShareResult),
                    PrimaryButton(title: localize(.share_keys_and_venues_reminder_screen_do_not_share_button_title), action: interactor.didTapDoNotShareResult),
                ],
                spacing: .standardSpacing,
                margins: .zero
            )
        }

    }
}

public class ShareKeysReminderViewController: StickyFooterScrollingContentViewController {

    public typealias Interacting = ShareKeysReminderViewControllerInteracting

    let interactor: Interacting

    public init(interactor: Interacting) {
        self.interactor = interactor
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
