//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import UIKit

public protocol IsolationPaymentInfoViewControllerInteracting {
    func didTapApply()
}

private class IsolationPaymentInfoContent: BasicStickyFooterScrollingContent {
    public typealias Interacting = IsolationPaymentInfoViewControllerInteracting
    
    private let interactor: Interacting
    
    public init(interactor: Interacting) {
        self.interactor = interactor
        
        super.init(
            scrollingViews: [
                UILabel().styleAsPageHeader().set(text: localize(.isolation_payment_info_header)),
                UILabel().styleAsBody().set(text: localize(.isolation_payment_info_description)),
            ],
            footerTopView: PrimaryLinkButton(
                title: localize(.isolation_payment_info_button),
                action: interactor.didTapApply
            )
        )
    }
}

public class IsolationPaymentInfoViewController: StickyFooterScrollingContentViewController {
    public typealias Interacting = IsolationPaymentInfoViewControllerInteracting
    
    private let content: IsolationPaymentInfoContent
    
    public init(interactor: Interacting) {
        content = IsolationPaymentInfoContent(interactor: interactor)
        super.init(content: content)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        title = localize(.isolation_payment_info_title)
        navigationController?.setNavigationBarHidden(false, animated: true)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: localize(.cancel), style: .done, target: self, action: #selector(didTapCancel))
    }
    
    @objc private func didTapCancel() {
        navigationController?.dismiss(animated: true)
    }
    
}
