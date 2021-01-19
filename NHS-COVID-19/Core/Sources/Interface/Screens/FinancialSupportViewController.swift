//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import UIKit

public protocol FinancialSupportViewControllerInteracting {
    func didTapHelpForEngland()
    func didTapHelpForWales()
    func didTapCheckEligibility()
    func didTapViewPrivacyNotice()
}

public class FinancialSupportViewController: ScrollingContentViewController {
    
    public typealias Interacting = FinancialSupportViewControllerInteracting
    
    public init(interactor: Interacting) {
        let content = FinancialSupportContent(interactor: interactor)
        super.init(views: content.views)
        title = localize(.financial_support_title)
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: localize(.cancel), style: .done, target: self, action: #selector(didTapCancel))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    @objc private func didTapCancel() {
        navigationController?.dismiss(animated: true)
    }
}

struct FinancialSupportContent {
    public typealias Interacting = FinancialSupportViewControllerInteracting
    var views: [StackViewContentProvider]
    
    init(interactor: Interacting) {
        let stackedViews = [
            BaseLabel().set(text: localize(.financial_support_title)).styleAsPageHeader(),
            BaseLabel().set(text: localize(.financial_support_description)).styleAsBody(),
            
            BaseLabel().set(text: localize(.financial_support_privacy_notice_description)).styleAsBody(),
            LinkButton(
                title: localize(.financial_support_privacy_notice_link_description),
                action: interactor.didTapViewPrivacyNotice
            ),
            
            BaseLabel().set(text: localize(.financial_support_help_england_link_description)).styleAsBody(),
            LinkButton(
                title: localize(.financial_support_help_england_link_title),
                action: interactor.didTapHelpForEngland
            ),
            
            BaseLabel().set(text: localize(.financial_support_help_wales_link_description)).styleAsBody(),
            LinkButton(
                title: localize(.financial_support_help_wales_link_title),
                action: interactor.didTapHelpForWales
            ),
        ]
        
        let contentStack = UIStackView(arrangedSubviews: stackedViews.flatMap { $0.content })
        contentStack.axis = .vertical
        contentStack.spacing = .standardSpacing
        
        let button = PrimaryLinkButton(
            title: localize(.financial_support_check_eligibility),
            action: interactor.didTapCheckEligibility
        )
        
        let stackContent = [contentStack, button]
        let stackView = UIStackView(arrangedSubviews: stackContent)
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = .standardSpacing
        
        views = [stackView]
    }
}
