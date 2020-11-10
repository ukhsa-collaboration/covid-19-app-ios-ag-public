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
            UILabel().styleAsPageHeader().set(text: localize(.virology_book_a_test_heading)),
            localizeAndSplit(.virology_book_a_test_description).map { UILabel().styleAsBody().set(text: String($0)) },
            UILabel().styleAsBody().set(text: localize(.virology_book_a_test_paragraph4)),
            LinkButton(
                title: localize(.virology_book_a_test_testing_privacy_notice),
                action: interactor.didTapTestingPrivacyNotice
            ),
            UILabel().styleAsBody().set(text: localize(.virology_book_a_test_paragraph5)),
            LinkButton(
                title: localize(.virology_book_a_test_app_privacy_notice),
                action: interactor.didTapAppPrivacyNotice
            ),
            PrimaryLinkButton(
                title: localize(.virology_book_a_test_button),
                action: interactor.didTapBookATest
            ),
            SecondaryLinkButton(
                title: localize(.virology_book_a_test_book_a_test_for_someone_else),
                action: interactor.didTapBookATestForSomeoneElse
            ),
        ]
    }
}

public class BookATestInfoViewController: ScrollingContentViewController {
    public typealias Interacting = BookATestInfoViewControllerInteracting
    
    private let shouldHaveCancelButton: Bool
    
    public init(interactor: Interacting, shouldHaveCancelButton: Bool) {
        self.shouldHaveCancelButton = shouldHaveCancelButton
        super.init(views: Self.content(interactor: interactor))
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
