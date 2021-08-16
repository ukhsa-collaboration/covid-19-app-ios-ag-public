//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import UIKit

public protocol GetAFreeTestKitViewControllerInteracting {
    func didTapAlreadyHaveATest()
    func didTapBookATest()
}

extension GetAFreeTestKitViewController {
    static func content(interactor: Interacting) -> [StackViewContentProvider] {
        [
            BaseLabel().styleAsPageHeader().set(text: localize(.get_a_free_test_kit_heading)),
            localizeAndSplit(.get_a_free_test_kit_description)
                .map { BaseLabel().styleAsBody().set(text: String($0)) },
        ]
    }
}

public class GetAFreeTestKitViewController: ScrollingContentViewController {
    public typealias Interacting = GetAFreeTestKitViewControllerInteracting
    
    public init(interactor: Interacting) {
        let contentStack = UIStackView(
            arrangedSubviews: Self.content(interactor: interactor).flatMap { $0.content }
        )
        contentStack.axis = .vertical
        contentStack.spacing = .standardSpacing
        
        let buttonStack = UIStackView(
            arrangedSubviews: [
                PrimaryLinkButton(
                    title: localize(.get_a_free_test_kit_submit_button),
                    action: interactor.didTapBookATest
                ),
                SecondaryButton(
                    title: localize(.get_a_free_test_kit_cancel_button),
                    action: interactor.didTapAlreadyHaveATest
                ),
            ]
        )
        buttonStack.axis = .vertical
        buttonStack.spacing = .standardSpacing
        
        let stackContent = [contentStack, buttonStack]
        let stackView = UIStackView(arrangedSubviews: stackContent)
        stackView.axis = .vertical
        stackView.distribution = .equalSpacing
        stackView.spacing = .standardSpacing
        
        super.init(views: [stackView])
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        title = localize(.get_a_free_test_kit_title)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
