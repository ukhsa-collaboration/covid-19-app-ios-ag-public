//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import UIKit

public protocol BookATestInfoViewControllerInteracting {
    func didTapTestingPrivacyNotice()
    func didTapAppPrivacyNotice()
    func didTapBookATestForSomeoneElse()
    func didTapBookATest()
}

extension BookATestInfoViewController {
    static func content(interactor: Interacting) -> [StackViewContentProvider] {
        [
            BaseLabel().styleAsPageHeader().set(text: localize(.virology_book_a_test_heading)),
            localizeAndSplit(.virology_book_a_test_description).map { BaseLabel().styleAsBody().set(text: String($0)) },
            BaseLabel().styleAsBody().set(text: localize(.virology_book_a_test_paragraph4)),
            LinkButton(
                title: localize(.virology_book_a_test_testing_privacy_notice),
                action: interactor.didTapTestingPrivacyNotice
            ),
            BaseLabel().styleAsBody().set(text: localize(.virology_book_a_test_paragraph5)),
            LinkButton(
                title: localize(.virology_book_a_test_app_privacy_notice),
                action: interactor.didTapAppPrivacyNotice
            ),
        ]
    }
}

public class BookATestInfoViewController: ScrollingContentViewController {
    public typealias Interacting = BookATestInfoViewControllerInteracting
    
    private let shouldHaveCancelButton: Bool
    
    public init(interactor: Interacting, shouldHaveCancelButton: Bool) {
        self.shouldHaveCancelButton = shouldHaveCancelButton
        
        let contentStack = UIStackView(
            arrangedSubviews: Self.content(interactor: interactor).flatMap { $0.content }
        )
        contentStack.axis = .vertical
        contentStack.spacing = .standardSpacing
        
        let buttonStack = UIStackView(
            arrangedSubviews: [
                PrimaryLinkButton(
                    title: localize(.virology_book_a_test_button),
                    action: interactor.didTapBookATest
                ),
                SecondaryLinkButton(
                    title: localize(.virology_book_a_test_book_a_test_for_someone_else),
                    action: interactor.didTapBookATestForSomeoneElse
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
        
        title = localize(.virology_book_a_test_title)
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        if shouldHaveCancelButton {
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: localize(.cancel), style: .done, target: self, action: #selector(didTapCancel))
        }
    }
    
    @objc private func didTapCancel() {
        navigationController?.dismiss(animated: true)
    }
}
