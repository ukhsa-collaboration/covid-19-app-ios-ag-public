//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import UIKit

public protocol BookARapidTestInfoViewControllerInteracting {
    func didTapAlreadyHaveATest()
    func didTapBookATest()
}

extension BookARapidTestInfoViewController {
    static func content(interactor: Interacting) -> [StackViewContentProvider] {
        [
            BaseLabel().styleAsPageHeader().set(text: localize(.virology_book_a_rapid_test_heading)),
            localizeAndSplit(.virology_book_a_rapid_test_description).map { BaseLabel().styleAsBody().set(text: String($0)) },
        ]
    }
}

public class BookARapidTestInfoViewController: ScrollingContentViewController {
    public typealias Interacting = BookARapidTestInfoViewControllerInteracting
    
    public init(interactor: Interacting) {
        
        let contentStack = UIStackView(
            arrangedSubviews: Self.content(interactor: interactor).flatMap { $0.content }
        )
        contentStack.axis = .vertical
        contentStack.spacing = .standardSpacing
        
        let buttonStack = UIStackView(
            arrangedSubviews: [
                PrimaryLinkButton(
                    title: localize(.virology_book_a_rapid_test_submit_button),
                    action: interactor.didTapBookATest
                ),
                SecondaryButton(
                    title: localize(.virology_book_a_rapid_test_cancel_button),
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
        
        title = localize(.virology_book_a_rapid_test_title)
        navigationController?.setNavigationBarHidden(false, animated: true)
    }
}
