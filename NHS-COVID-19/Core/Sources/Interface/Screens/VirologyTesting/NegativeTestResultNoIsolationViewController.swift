//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol NegativeTestResultNoIsolationViewControllerInteracting {
    func didTapOnlineServicesLink()
    func didTapReturnHome()
}

public class NegativeTestResultNoIsolationViewController: UIViewController {
    
    public typealias Interacting = NegativeTestResultNoIsolationViewControllerInteracting
    
    private let interactor: Interacting
    
    public init(interactor: Interacting) {
        self.interactor = interactor
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
        
        let image = UIImageView(.isolationEndedWarning)
        image.adjustsImageSizeForAccessibilityContentSizeCategory = true
        image.styleAsDecoration()
        
        let titleLabel = UILabel()
        titleLabel.text = localize(.negative_test_result_no_isolation_title)
        titleLabel.styleAsPageHeader()
        titleLabel.textAlignment = .center
        
        let endOfIsolationLabel = UILabel()
        endOfIsolationLabel.text = localize(.negative_test_result_no_isolation_description)
        endOfIsolationLabel.styleAsHeading()
        endOfIsolationLabel.textAlignment = .center
        
        let goodNewsStack = UIStackView(arrangedSubviews: [titleLabel, endOfIsolationLabel])
        goodNewsStack.axis = .vertical
        
        let infobox = InformationBox.indication.warning(localize(.negative_test_result_no_isolation_warning))
        
        let linkLabel = UILabel()
        linkLabel.text = localize(.negative_test_result_no_isolation_link_hint)
        linkLabel.styleAsSecondaryBody()
        
        let onlineServicesLink = LinkButton(title: localize(.negative_test_result_no_isolation_link_label))
        onlineServicesLink.addTarget(self, action: #selector(didTapOnlineServicesLink), for: .touchUpInside)
        
        let stack = UIStackView(arrangedSubviews: [spacer, image, goodNewsStack, infobox, linkLabel, onlineServicesLink])
        stack.axis = .vertical
        stack.spacing = .standardSpacing
        stack.isLayoutMarginsRelativeArrangement = true
        stack.layoutMargins = .standard
        
        let scrollView = UIScrollView()
        scrollView.addFillingSubview(stack)
        
        let backToHomeButton = UIButton()
        backToHomeButton.setTitle(localize(.negative_test_result_no_isolation_button_label), for: .normal)
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
            scrollView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            bottomButtonStack.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            bottomButtonStack.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            bottomButtonStack.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            stack.widthAnchor.constraint(equalTo: view.readableContentGuide.widthAnchor),
        ])
    }
    
    @objc func didTapOnlineServicesLink() {
        interactor.didTapOnlineServicesLink()
    }
    
    @objc func didTapReturnHome() {
        interactor.didTapReturnHome()
    }
}
