//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol EndOfIsolationViewControllerInteracting {
    func didTapOnlineServicesLink()
    func didTapReturnHome()
}

public class EndOfIsolationViewController: UIViewController {
    
    public typealias Interacting = EndOfIsolationViewControllerInteracting
    
    private let interactor: Interacting
    private let isolationEndDate: Date
    private let showAdvisory: Bool
    
    public init(interactor: Interacting, isolationEndDate: Date, showAdvisory: Bool) {
        self.interactor = interactor
        self.isolationEndDate = isolationEndDate
        self.showAdvisory = showAdvisory
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
        
        let checkmark = UIImageView(.checkmark)
        checkmark.adjustsImageSizeForAccessibilityContentSizeCategory = true
        checkmark.styleAsDecoration()
        checkmark.tintColor = UIColor(.nhsButtonGreen)
        
        let titleLabel = UILabel()
        titleLabel.text = localize(.end_of_isolation_isolate_title)
        titleLabel.styleAsPageHeader()
        titleLabel.textAlignment = .center
        titleLabel.isAccessibilityElement = false
        
        let endOfIsolationLabel = UILabel()
        if isolationEndDate < Date() {
            endOfIsolationLabel.text = localize(.end_of_isolation_has_passed_description(at: isolationEndDate))
        } else {
            endOfIsolationLabel.text = localize(.end_of_isolation_is_near_description(at: isolationEndDate))
        }
        endOfIsolationLabel.styleAsHeading()
        endOfIsolationLabel.textAlignment = .center
        endOfIsolationLabel.isAccessibilityElement = false
        
        let infobox = InformationBox.indication.warning(localize(.end_of_isolation_isolate_if_have_symptom_warning))
        
        infobox.isHidden = !showAdvisory
        
        let explanation1Label = UILabel()
        explanation1Label.text = localize(.end_of_isolation_explanation_1)
        explanation1Label.styleAsBody()
        explanation1Label.isHidden = showAdvisory
        
        let linkLabel = mutating(UILabel()) {
            $0.styleAsBody()
            $0.text = localize(.end_of_isolation_link_label)
        }
        
        let onlineServicesLink = LinkButton(
            title: localize(.end_of_isolation_online_services_link),
            textAlignment: .left
        )
        onlineServicesLink.addTarget(self, action: #selector(didTapOnlineServicesLink), for: .touchUpInside)
        
        let backToHomeTestButton = UIButton()
        backToHomeTestButton.setTitle(localize(.end_of_isolation_corona_back_to_home_button), for: .normal)
        backToHomeTestButton.styleAsPrimary()
        backToHomeTestButton.setContentHuggingPriority(.defaultLow, for: .horizontal)
        backToHomeTestButton.addTarget(self, action: #selector(didTapReturnHome), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [checkmark, titleLabel, endOfIsolationLabel, infobox, explanation1Label, linkLabel, onlineServicesLink])
        stack.axis = .vertical
        stack.spacing = .standardSpacing
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = .largeInset
        
        let scrollView = UIScrollView()
        scrollView.addFillingSubview(stack)
        
        view.addAutolayoutSubview(scrollView)
        view.addAutolayoutSubview(backToHomeTestButton)
        
        NSLayoutConstraint.activate([
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: backToHomeTestButton.topAnchor, constant: -.doubleSpacing),
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            stack.widthAnchor.constraint(equalTo: view.safeAreaLayoutGuide.widthAnchor, multiplier: 1),
            
            backToHomeTestButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: .doubleSpacing),
            backToHomeTestButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -.doubleSpacing),
            backToHomeTestButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -.standardSpacing),
        ])
    }
    
    @objc func didTapOnlineServicesLink() {
        interactor.didTapOnlineServicesLink()
    }
    
    @objc func didTapReturnHome() {
        interactor.didTapReturnHome()
    }
}
