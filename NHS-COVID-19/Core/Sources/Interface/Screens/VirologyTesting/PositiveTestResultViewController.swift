//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Localization
import UIKit

public protocol PositiveTestResultViewControllerInteracting {
    func didTapOnlineServicesLink()
    func didTapContinue()
}

public class PositiveTestResultViewController: UIViewController {
    private var shareKeysCancellable = [AnyCancellable]()
    
    public typealias Interacting = PositiveTestResultViewControllerInteracting
    
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
        
        let indicationLabel = UILabel()
        indicationLabel.text = localize(.positive_test_result_info)
        indicationLabel.styleAsSecondaryTitle()
        
        let infobox = InformationBox(views: [indicationLabel], style: .badNews)
        
        let explanationLabel = UILabel()
        explanationLabel.text = localize(.positive_test_result_explanation)
        explanationLabel.styleAsSecondaryBody()
        
        let linkLabel = UILabel()
        linkLabel.text = localize(.end_of_isolation_link_label)
        linkLabel.styleAsSecondaryBody()
        
        let onlineServicesLink = LinkButton(title: localize(.end_of_isolation_online_services_link))
        onlineServicesLink.addTarget(self, action: #selector(didTapOnlineServicesLink), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [spacer, padlock, pleaseIsolateStack, infobox, explanationLabel, linkLabel, onlineServicesLink])
        stack.axis = .vertical
        stack.spacing = .standardSpacing
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = .standard
        
        let scrollView = UIScrollView()
        scrollView.addFillingSubview(stack)
        
        let continueButton = UIButton()
        continueButton.setTitle(localize(.positive_test_results_continue), for: .normal)
        continueButton.styleAsPrimary()
        continueButton.setContentHuggingPriority(.defaultLow, for: .horizontal)
        continueButton.addTarget(self, action: #selector(didTapContinue), for: .touchUpInside)
        
        let bottomButtonStack = UIStackView(arrangedSubviews: [continueButton])
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
    
    @objc func didTapContinue() {
        interactor.didTapContinue()
    }
}
