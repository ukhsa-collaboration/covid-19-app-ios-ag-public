//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol BookAFollowUpTestViewControllerInteracting {
    var didTapNHSGuidanceLink: () -> Void { get }
    var didTapPrimaryButton: () -> Void { get }
    var didTapCancel: () -> Void { get }
}

private class BookAFollowUpTestContent: PrimaryButtonStickyFooterScrollingContent {
    typealias Interacting = BookAFollowUpTestViewControllerInteracting

    init(interactor: Interacting) {
        super.init(
            scrollingViews: [
                UIImageView(.isolationStartIndex).styleAsDecoration(),
                BaseLabel()
                    .styleAsPageHeader()
                    .set(text: localize(.book_a_follow_up_test_header))
                    .centralized(),
                InformationBox.indication.badNews(localize(.book_a_follow_up_test_info)),
                localizeAndSplit(.book_a_follow_up_test_body).map {
                    BaseLabel().styleAsSecondaryBody().set(text: $0)
                },
                BaseLabel().styleAsSecondaryBody().set(text: localize(.book_a_follow_up_test_advice_link_title)),
                LinkButton(
                    title: localize(.book_a_follow_up_test_advice_link),
                    action: interactor.didTapNHSGuidanceLink
                ),
            ],
            primaryButton: (title: localize(.book_a_follow_up_test_button), action: interactor.didTapPrimaryButton)
        )
    }
}

public final class BookAFollowUpTestViewController: StickyFooterScrollingContentViewController {
    public typealias Interacting = BookAFollowUpTestViewControllerInteracting

    private let interactor: Interacting

    public init(interactor: Interacting) {
        self.interactor = interactor
        let content = BookAFollowUpTestContent(interactor: interactor)
        super.init(content: content)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        navigationController?.setNavigationBarHidden(false, animated: animated)
        navigationItem.leftBarButtonItem = UIBarButtonItem(
            title: localize(.book_a_follow_up_test_close_button),
            style: .done,
            target: self,
            action: #selector(didTapCancel)
        )
    }

    override public func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        setNavigationBarTransparent(false)
    }

    private func setNavigationBarTransparent(_ isTransparent: Bool) {
        let image = isTransparent ? UIImage() : nil
        navigationController?.navigationBar.setBackgroundImage(image, for: .default)
        navigationController?.navigationBar.shadowImage = image
        navigationController?.navigationBar.isTranslucent = isTransparent
    }

    @objc
    private func didTapCancel() {
        interactor.didTapCancel()
    }
}
