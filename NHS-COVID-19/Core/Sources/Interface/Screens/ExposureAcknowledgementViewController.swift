//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Localization
import UIKit

public protocol ExposureAcknowledgementViewControllerInteracting {
    func acknowledge()
    func didTapOnlineLink()
}

public class ExposureAcknowledgementViewController: UIViewController {
    public typealias Interacting = ExposureAcknowledgementViewControllerInteracting
    
    let interactor: Interacting
    let duration: Int
    
    public init(interactor: Interacting, isolationEndDate: Date) {
        self.interactor = interactor
        duration = LocalDay.today.daysRemaining(until: isolationEndDate)
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private var padlockImageView: UIImageView = {
        let view = UIImageView(.padlock)
        view.adjustsImageSizeForAccessibilityContentSizeCategory = true
        view.styleAsDecoration()
        return view
    }()
    
    private var selfIsolateLabel: UILabel = {
        let label = UILabel()
        label.text = localize(.exposure_acknowledgement_self_isolate_for)
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
        label.text = localize(.exposure_acknowledgement_days(days: duration))
        return label
    }()
    
    private let explainationLabel1: UILabel = {
        let label = UILabel()
        label.styleAsBody()
        label.text = localize(.exposure_acknowledgement_explaination_1)
        return label
    }()
    
    private let explainationLabel2: UILabel = {
        let label = UILabel()
        label.styleAsBody()
        label.text = localize(.exposure_acknowledgement_explaination_2)
        return label
    }()
    
    private let exposureAcknowledgementLinkLabel: UILabel = {
        let label = UILabel()
        label.styleAsBody()
        label.text = localize(.exposure_acknowledgement_link_label)
        return label
    }()
    
    private lazy var exposureAcknowledgementLink = mutating(LinkButton(title: localize(.exposure_acknowledgement_link))) {
        $0.addTarget(self, action: #selector(openLink), for: .touchUpInside)
    }
    
    @objc func openLink() {
        interactor.didTapOnlineLink()
    }
    
    private let acknowledgementButton: UIButton = {
        let button = UIButton()
        button.setTitle(localize(.exposure_acknowledgement_button), for: .normal)
        button.styleAsPrimary()
        button.setContentHuggingPriority(.defaultLow, for: .horizontal)
        button.addTarget(self, action: #selector(acknowledgementButtonTapped), for: .touchUpInside)
        return button
    }()
    
    private lazy var acknowledgementButtonContainer: UIView = {
        let container = UIView()
        container.addFillingSubview(acknowledgementButton, inset: .standardSpacing)
        return container
    }()
    
    private lazy var pleaseIsolateStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [selfIsolateLabel, daysLabel])
        stack.axis = .vertical
        stack.isAccessibilityElement = true
        stack.accessibilityTraits = [.staticText]
        stack.accessibilityLabel = localize(.exposure_acknowledgement_please_isolate_accessibility_label(days: duration))
        return stack
    }()
    
    private lazy var contentStack: UIStackView = {
        let stack = UIStackView(arrangedSubviews: [
            padlockImageView,
            pleaseIsolateStack,
            InformationBox.indication.warning(localize(.exposure_acknowledgement_warning)),
            explainationLabel1,
            explainationLabel2,
            exposureAcknowledgementLinkLabel,
            exposureAcknowledgementLink,
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
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        view.styleAsScreenBackground(with: traitCollection)
        
        view.addAutolayoutSubview(scrollView)
        view.addAutolayoutSubview(acknowledgementButtonContainer)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            acknowledgementButtonContainer.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            acknowledgementButtonContainer.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            contentStack.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
            
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            acknowledgementButtonContainer.topAnchor.constraint(equalTo: scrollView.bottomAnchor),
            acknowledgementButtonContainer.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor).withPriority(.defaultHigh),
        ])
    }
    
    @objc func acknowledgementButtonTapped() {
        interactor.acknowledge()
    }
}
