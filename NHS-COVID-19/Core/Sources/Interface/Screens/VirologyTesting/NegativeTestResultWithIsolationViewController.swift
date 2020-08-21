//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol NegativeTestResultWithIsolationViewControllerInteracting {
    func didTapOnlineServicesLink()
    func didTapReturnHome()
    
}

public class NegativeTestResultWithIsolationViewController: UIViewController {
    
    public typealias Interacting = NegativeTestResultWithIsolationViewControllerInteracting
    private let interactor: Interacting
    private let isolationEndDate: Date
    
    public init(interactor: Interacting, isolationEndDate: Date) {
        self.interactor = interactor
        self.isolationEndDate = isolationEndDate
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.setNavigationBarHidden(true, animated: false)
        
        let view = self.view!
        view.styleAsScreenBackground(with: traitCollection)
        
        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: .bigSpacing).isActive = true
        
        let padlock = UIImageView(.padlock)
        padlock.adjustsImageSizeForAccessibilityContentSizeCategory = true
        padlock.styleAsDecoration()
        
        let titleLabel = UILabel()
        titleLabel.text = localize(.positive_test_result_title)
        titleLabel.styleAsHeading()
        titleLabel.textAlignment = .center
        titleLabel.isAccessibilityElement = false
        
        let daysToIsolate = LocalDay.today.daysRemaining(until: isolationEndDate)
        
        let daysLabel = UILabel()
        daysLabel.text = localize(.positive_symptoms_days(days: daysToIsolate))
        daysLabel.styleAsPageHeader()
        daysLabel.textAlignment = .center
        daysLabel.isAccessibilityElement = false
        
        let pleaseIsolateStack = UIStackView(arrangedSubviews: [titleLabel, daysLabel])
        pleaseIsolateStack.axis = .vertical
        pleaseIsolateStack.isAccessibilityElement = true
        pleaseIsolateStack.accessibilityTraits = [.staticText]
        pleaseIsolateStack.accessibilityLabel = localize(.positive_test_please_isolate_accessibility_label(days: daysToIsolate))
        
        let infobox = InformationBox.indication.warning(localize(.negative_test_result_with_isolation_info))
        
        let explanationLabel = UILabel()
        explanationLabel.text = localize(.negative_test_result_with_isolation_explanation)
        explanationLabel.styleAsSecondaryBody()
        
        let furtherAdviceLabel = UILabel()
        furtherAdviceLabel.text = localize(.negative_test_result_with_isolation_advice)
        furtherAdviceLabel.styleAsSecondaryBody()
        
        let onlineServicesLink = LinkButton(
            title: localize(.negative_test_result_with_isolation_service_link),
            textAlignment: .left
        )
        
        onlineServicesLink.addTarget(self, action: #selector(didTapOnlineServicesLink), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [spacer, padlock, pleaseIsolateStack, infobox, explanationLabel, furtherAdviceLabel, onlineServicesLink])
        stack.axis = .vertical
        stack.spacing = .standardSpacing
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = .standard
        
        let scrollView = UIScrollView()
        scrollView.addFillingSubview(stack)
        
        let backToHomeButton = UIButton()
        backToHomeButton.setTitle(localize(.negative_test_result_with_isolation_back_to_home), for: .normal)
        backToHomeButton.styleAsPrimary()
        backToHomeButton.setContentHuggingPriority(.defaultLow, for: .horizontal)
        backToHomeButton.addTarget(self, action: #selector(didTapReturnHome), for: .touchUpInside)
        
        let bottomButtonStack = UIStackView(arrangedSubviews: [backToHomeButton])
        bottomButtonStack.axis = .vertical
        bottomButtonStack.spacing = .standardSpacing
        bottomButtonStack.isLayoutMarginsRelativeArrangement = true
        bottomButtonStack.layoutMargins = .standard
        
        view.addAutolayoutSubview(scrollView)
        view.addAutolayoutSubview(bottomButtonStack)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: bottomButtonStack.topAnchor, constant: -.standardSpacing),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            bottomButtonStack.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            bottomButtonStack.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            bottomButtonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stack.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor),
        ])
    }
    
    @objc func didTapOnlineServicesLink() {
        interactor.didTapOnlineServicesLink()
    }
    
    @objc func didTapReturnHome() {
        interactor.didTapReturnHome()
    }
}
