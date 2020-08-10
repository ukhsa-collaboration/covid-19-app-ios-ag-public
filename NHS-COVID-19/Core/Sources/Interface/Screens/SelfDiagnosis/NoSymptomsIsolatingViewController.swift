//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol NoSymptomsIsolatingViewControllerInteracting {
    func didTapReturnHome()
    func didTapCancel()
    func didTapOnlineServicesLink()
}

public class NoSymptomsIsolatingViewController: UIViewController {
    
    public typealias Interacting = NoSymptomsIsolatingViewControllerInteracting
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
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .cancel, target: self, action: #selector(didTapCancel))
        
        let view = self.view!
        view.styleAsScreenBackground(with: traitCollection)
        
        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: .bigSpacing).isActive = true
        
        let padlock = UIImageView(.padlock)
        padlock.adjustsImageSizeForAccessibilityContentSizeCategory = true
        padlock.styleAsDecoration()
        
        let titleLabel = UILabel()
        titleLabel.text = localize(.no_symptoms_isolating_info_isolate_for)
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
        
        let indicationLabel = UILabel()
        indicationLabel.text = localize(.no_symptoms_isolating_info)
        indicationLabel.styleAsSecondaryTitle()
        
        let infobox = InformationBox(views: [indicationLabel], style: .goodNews, backgroundColor: UIColor(.surface))
        
        let explanationLabel = UILabel()
        explanationLabel.text = localize(.no_symptoms_isolating_body)
        explanationLabel.styleAsSecondaryBody()
        
        let furtherAdviceLabel = UILabel()
        furtherAdviceLabel.text = localize(.no_symptoms_isolating_advice)
        furtherAdviceLabel.styleAsSecondaryBody()
        
        let onlineServicesLink = LinkButton(
            title: localize(.no_symptoms_isolating_services_link),
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
        backToHomeButton.setTitle(localize(.no_symptoms_isolating_return_home_button), for: .normal)
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
    
    @objc func didTapCancel() {
        interactor.didTapCancel()
    }
}
