//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol PositiveSymptomsViewControllerInteracting {
    func didTapBookTest()
    func didTapCancel()
    func furtherAdviceLinkTapped()
}

public class PositiveSymptomsViewController: UIViewController {
    
    public typealias Interacting = PositiveSymptomsViewControllerInteracting
    
    private let interactor: Interacting
    let duration: Int
    
    public init(interactor: Interacting, isolationEndDate: Date) {
        self.interactor = interactor
        duration = LocalDay.today.daysRemaining(until: isolationEndDate)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var imageView: UIImageView = {
        let view = UIImageView(.isolationStartIndex)
        view.adjustsImageSizeForAccessibilityContentSizeCategory = true
        view.styleAsDecoration()
        return view
    }()
    
    private var selfIsolateLabel: UILabel = {
        let label = UILabel()
        label.text = localize(.positive_symptoms_please_isolate_for)
        label.styleAsHeading()
        label.textAlignment = .center
        label.isAccessibilityElement = false
        return label
    }()
    
    private lazy var daysLabel: UILabel = {
        let label = UILabel()
        label.styleAsPageHeader()
        label.textAlignment = .center
        label.isAccessibilityElement = false
        label.text = localize(.positive_symptoms_days(days: duration))
        return label
    }()
    
    public lazy var bookATestLabel: UILabel = {
        let label = UILabel()
        label.text = localize(.positive_symptoms_and_book_a_test)
        label.styleAsHeading()
        label.textAlignment = .center
        label.isAccessibilityElement = false
        return label
    }()
    
    private let explainationLabel: UILabel = {
        let label = UILabel()
        label.styleAsBody()
        label.text = localize(.positive_symptoms_explanation)
        return label
    }()
    
    private let bookATestButton: UIButton = {
        let button = UIButton()
        button.setTitle(localize(.positive_symptoms_corona_test_button), for: .normal)
        button.styleAsPrimary()
        button.setContentHuggingPriority(.defaultLow, for: .horizontal)
        button.addTarget(self, action: #selector(didTapBookTest), for: .touchUpInside)
        return button
    }()
    
    private lazy var acknowledgementButtonContainer: UIView = {
        let container = UIView()
        container.addFillingSubview(bookATestButton, inset: .standardSpacing)
        return container
    }()
    
    private lazy var pleaseIsolateStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [selfIsolateLabel, daysLabel, bookATestLabel])
        stack.axis = .vertical
        stack.isAccessibilityElement = true
        stack.accessibilityTraits = [.staticText]
        stack.accessibilityLabel = localize(.positive_symptoms_please_isolate_accessibility_label(days: duration))
        return stack
    }()
    
    private lazy var linkLabel: UILabel = {
        let label = UILabel()
        label.styleAsBody()
        label.text = localize(.positive_symptoms_link_label)
        return label
    }()
    
    private lazy var furtherAdviceLink: LinkButton = {
        let furtherAdviceLink = LinkButton(title: localize(.end_of_isolation_online_services_link))
        furtherAdviceLink.addTarget(self, action: #selector(didTapFurtherAdviceLink), for: .touchUpInside)
        return furtherAdviceLink
    }()
    
    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            imageView,
            pleaseIsolateStack,
            InformationBox.indication.warning(localize(.positive_symptoms_you_might_have_corona)),
            explainationLabel,
            linkLabel,
            furtherAdviceLink,
        ])
        stack.axis = .vertical
        stack.spacing = .standardSpacing
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = .standard
        return stack
    }()
    
    private lazy var scrollView: UIScrollView = {
        let scrollView = UIScrollView()
        scrollView.addFillingSubview(contentStack)
        return scrollView
    }()
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: localize(.cancel), style: .done, target: self, action: #selector(didTapCancel))
        view.styleAsScreenBackground(with: traitCollection)
        
        view.addAutolayoutSubview(scrollView)
        view.addAutolayoutSubview(acknowledgementButtonContainer)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            acknowledgementButtonContainer.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            acknowledgementButtonContainer.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            contentStack.widthAnchor.constraint(equalTo: view.readableContentGuide.widthAnchor),
            
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            acknowledgementButtonContainer.topAnchor.constraint(equalTo: scrollView.bottomAnchor),
            acknowledgementButtonContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).withPriority(.defaultHigh),
        ])
    }
    
    @objc func didTapBookTest() {
        interactor.didTapBookTest()
    }
    
    @objc func didTapCancel() {
        interactor.didTapCancel()
    }
    
    @objc func didTapFurtherAdviceLink() {
        interactor.furtherAdviceLinkTapped()
    }
}
