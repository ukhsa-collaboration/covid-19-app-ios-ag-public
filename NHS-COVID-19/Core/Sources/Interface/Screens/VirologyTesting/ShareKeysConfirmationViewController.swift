//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol ShareKeysConfirmationViewControllerInteracting {
    var didTapIUnderstand: () -> Void { get }
    var didTapBack: () -> Void { get }
}

private class ShareKeysConfirmationContent: StickyFooterScrollingContent {
    typealias Interacting = ShareKeysConfirmationViewControllerInteracting
    static let infoboxInset = (.stripeWidth + .stripeSpacing)
    
    var scrollingContent: StackContent
    var footerContent: StackContent?
    var spacing: CGFloat
    
    init(interactor: Interacting) {
        scrollingContent = BasicContent(
            views: [
                UIStackView(content: BasicContent(
                    views: [BaseLabel().styleAsPageHeader().set(text: localize(.share_keys_confirmation_heading))],
                    spacing: 0,
                    margins: mutating(.zero) {
                        $0.left = Self.infoboxInset
                        $0.right = Self.infoboxInset
                    }
                )),
                InformationBox.information(
                    .title(.share_keys_confirmation_info_title),
                    .body(.share_keys_confirmation_info_body)
                ),
            ],
            spacing: .standardSpacing,
            margins: mutating(.largeInset) {
                $0.bottom = 0
                $0.left -= Self.infoboxInset
                $0.right -= Self.infoboxInset
            }
        )
        
        footerContent = BasicContent(
            views: [PrimaryButton(
                title: localize(.share_keys_confirmation_i_understand),
                action: interactor.didTapIUnderstand
            )],
            spacing: .standardSpacing,
            margins: mutating(.largeInset) { $0.top = 0 }
        )
        
        spacing = .doubleSpacing
    }
}

public class ShareKeysConfirmationViewController: StickyFooterScrollingContentViewController {
    public typealias Interacting = ShareKeysConfirmationViewControllerInteracting
    let interactor: Interacting
    
    public init(interactor: Interacting) {
        self.interactor = interactor
        super.init(content: ShareKeysConfirmationContent(interactor: interactor))
        title = localize(.share_keys_confirmation_title)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: localize(.back), style: .done, target: self, action: #selector(didTapBack))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    @objc private func didTapBack() {
        interactor.didTapBack()
    }
    
}
