//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol PolicyUpdateViewControllerInteracting {
    func didTapContinue()
    func didTapTermsOfUse()
}

struct PolicyUpdateContent {
    public typealias Interacting = PolicyUpdateViewControllerInteracting
    
    var views: [StackViewContentProvider]
    
    private let interactor: Interacting
    
    public init(interactor: Interacting) {
        self.interactor = interactor
        
        views = [
            LogoStrapline(.nhsBlue, style: .onboarding),
            UIImageView(.policy).styleAsDecoration(),
            UILabel().styleAsPageHeader().set(text: localize(.policy_update_title)),
            localizeAndSplit(.policy_update_description).map { UILabel().styleAsBody().set(text: String($0)) },
            LinkButton(
                title: localize(.terms_of_use_label),
                action: interactor.didTapTermsOfUse
            ),
        ]
        
        let contentStack = UIStackView(arrangedSubviews: views.flatMap { $0.content })
        contentStack.axis = .vertical
        contentStack.spacing = .standardSpacing
        
        let button = PrimaryButton(
            title: localize(.policy_update_button),
            action: interactor.didTapContinue
        )
        
        let stackContent = [contentStack, button]
        let stackView = UIStackView(arrangedSubviews: stackContent)
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = .standardSpacing
        
        views = [stackView]
        
    }
}

public class PolicyUpdateViewController: ScrollingContentViewController {
    public typealias Interacting = PolicyUpdateViewControllerInteracting
    
    private let content: PolicyUpdateContent
    
    public init(interactor: Interacting) {
        content = PolicyUpdateContent(interactor: interactor)
        super.init(views: content.views)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
}
