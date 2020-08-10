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

public class BookATestInfoViewController: UIViewController {
    
    public typealias Interacting = BookATestInfoViewControllerInteracting
    
    private let interactor: Interacting
    private let shouldHaveCancelButton: Bool
    
    public init(interactor: Interacting, shouldHaveCancelButton: Bool) {
        self.interactor = interactor
        self.shouldHaveCancelButton = shouldHaveCancelButton
        
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private let headingLabel: UILabel = {
        let label = UILabel()
        label.styleAsPageHeader()
        label.text = localize(.virology_book_a_test_heading)
        return label
    }()
    
    private lazy var testPrivaceNoticecStackView: UIStackView = {
        
        let label = makeLabelWith(.virology_book_a_test_paragraph4)
        
        let testingPrivacyNoticeButton = LinkButton(
            title: localize(.virology_book_a_test_testing_privacy_notice)
        )
        
        testingPrivacyNoticeButton.addTarget(self, action: #selector(didTapTestingPrivacyNotice), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [label, testingPrivacyNoticeButton])
        stackView.axis = .vertical
        stackView.spacing = .halfSpacing
        
        return stackView
    }()
    
    private lazy var testAppNoticecStackView: UIStackView = {
        
        let label = makeLabelWith(.virology_book_a_test_paragraph5)
        
        let button = LinkButton(
            title: localize(.virology_book_a_test_app_privacy_notice)
        )
        
        button.addTarget(self, action: #selector(didTapAppPrivacyNotice), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [label, button])
        stackView.axis = .vertical
        stackView.spacing = .halfSpacing
        
        return stackView
    }()
    
    private lazy var bookATestForSomeoneElsetackView: UIStackView = {
        
        let label = makeLabelWith(.virology_book_a_test_paragraph6)
        
        let button = LinkButton(
            title: localize(.virology_book_a_test_book_a_test_for_someone_else)
        )
        
        button.addTarget(self, action: #selector(didTapBookATestForSomeoneElse), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [label, button])
        stackView.axis = .vertical
        stackView.spacing = .halfSpacing
        
        return stackView
    }()
    
    private func makeLabelWith(_ localizedKey: StringLocalizationKey) -> UILabel {
        let label = UILabel()
        label.styleAsBody()
        label.text = localize(localizedKey)
        return label
    }
    
    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            headingLabel,
            makeLabelWith(.virology_book_a_test_paragraph1),
            makeLabelWith(.virology_book_a_test_paragraph2),
            makeLabelWith(.virology_book_a_test_paragraph3),
            testPrivaceNoticecStackView,
            testAppNoticecStackView,
            bookATestForSomeoneElsetackView,
            bookATestButton,
        ])
        stack.axis = .vertical
        stack.spacing = .standardSpacing
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = .largeInset
        return stack
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.addFillingSubview(contentStack)
        return scrollView
    }()
    
    private let bookATestButton: UIButton = {
        let button = UIButton()
        button.setTitle(localize(.virology_book_a_test_button), for: .normal)
        button.styleAsPrimary()
        
        button.setContentHuggingPriority(.defaultLow, for: .horizontal)
        button.addTarget(self, action: #selector(didTapBookATest), for: .touchUpInside)
        return button
    }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        title = localize(.virology_book_a_test_title)
        
        navigationController?.setNavigationBarHidden(false, animated: true)
        
        if shouldHaveCancelButton {
            navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel))
        }
        
        view.styleAsScreenBackground(with: traitCollection)
        view.addAutolayoutSubview(scrollView)
        view.addAutolayoutSubview(bookATestButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            contentStack.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
            
            bookATestButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: .doubleSpacing),
            bookATestButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -.doubleSpacing),
            bookATestButton.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: .doubleSpacing),
            bookATestButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -.doubleSpacing),
        ])
    }
    
    @objc private func didTapBookATest() {
        interactor.didTapBookATest()
    }
    
    @objc private func didTapTestingPrivacyNotice() {
        interactor.didTapTestingPrivacyNotice()
    }
    
    @objc private func didTapAppPrivacyNotice() {
        interactor.didTapAppPrivacyNotice()
    }
    
    @objc private func didTapBookATestForSomeoneElse() {
        interactor.didTapBookATestForSomeoneElse()
    }
    
    @objc private func didTapCancel() {
        navigationController?.dismiss(animated: true)
    }
}
