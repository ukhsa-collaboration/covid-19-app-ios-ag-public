//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Localization
import UIKit

public protocol NonNegativeTestResultNoIsolationViewControllerInteracting {
    var didTapOnlineServicesLink: () -> Void { get }
    var didTapPrimaryButton: () -> Void { get }
    var didTapCancel: (() -> Void)? { get }
}

public class NonNegativeTestResultNoIsolationViewController: UIViewController {
    
    public enum TestResultType {
        case void, positive
        
        var headerText: String {
            switch self {
            case .positive:
                return localize(.end_of_isolation_positive_text_no_isolation_header)
            case .void:
                return localize(.void_test_result_no_isolation_header)
            }
        }
        
        var titleText: String {
            switch self {
            case .positive:
                return localize(.end_of_isolation_positive_text_no_isolation_title)
            case .void:
                return localize(.void_test_result_no_isolation_title)
            }
        }
        
        var continueButtonTitle: String {
            switch self {
            case .positive:
                return localize(.positive_test_results_continue)
            case .void:
                return localize(.void_test_results_continue)
            }
        }
    }
    
    public typealias Interacting = NonNegativeTestResultNoIsolationViewControllerInteracting
    
    private let interactor: Interacting
    private let testResultType: TestResultType
    public init(interactor: Interacting, testResultType: TestResultType = .positive) {
        self.interactor = interactor
        self.testResultType = testResultType
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let view = self.view!
        view.styleAsScreenBackground(with: traitCollection)
        
        let spacer = UIView()
        spacer.heightAnchor.constraint(equalToConstant: .bigSpacing).isActive = true
        
        let image = UIImageView(.isolationEndedWarning)
        image.adjustsImageSizeForAccessibilityContentSizeCategory = true
        image.styleAsDecoration()
        
        let headerLabel = UILabel()
        headerLabel.text = testResultType.headerText
        headerLabel.styleAsPageHeader()
        headerLabel.textAlignment = .center
        
        let titleLabel = UILabel()
        titleLabel.text = testResultType.titleText
        titleLabel.styleAsHeading()
        titleLabel.textAlignment = .center
        
        let headingStack = UIStackView(arrangedSubviews: [headerLabel, titleLabel])
        headingStack.axis = .vertical
        
        let infobox = InformationBox.indication.warning(localize(.end_of_isolation_isolate_if_have_symptom_warning))
        
        let explanationLabel = UILabel()
        explanationLabel.text = localize(.end_of_isolation_further_advice_visit)
        explanationLabel.styleAsBody()
        
        let onlineServicesLink = LinkButton(title: localize(.end_of_isolation_online_services_link))
        onlineServicesLink.addTarget(self, action: #selector(didTapOnlineServicesLink), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [spacer, image, headingStack, infobox, explanationLabel, onlineServicesLink])
        stackView.axis = .vertical
        stackView.spacing = .standardSpacing
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .standard
        
        let continueButton = UIButton()
        continueButton.setTitle(testResultType.continueButtonTitle, for: .normal)
        continueButton.styleAsPrimary()
        continueButton.setContentHuggingPriority(.defaultLow, for: .horizontal)
        continueButton.addTarget(self, action: #selector(didTapPrimaryButton), for: .touchUpInside)
        
        let stackViewContainerView = UIView()
        stackViewContainerView.addAutolayoutSubview(stackView)
        
        let scrollView = UIScrollView()
        scrollView.addFillingSubview(stackViewContainerView)
        
        view.addAutolayoutSubview(scrollView)
        view.addAutolayoutSubview(continueButton)
        
        NSLayoutConstraint.activate([
            stackViewContainerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor),
            
            stackView.centerYAnchor.constraint(equalTo: stackViewContainerView.centerYAnchor),
            stackView.topAnchor.constraint(greaterThanOrEqualTo: stackViewContainerView.topAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: stackViewContainerView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: stackViewContainerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: stackViewContainerView.trailingAnchor),
            
            stackViewContainerView.heightAnchor.constraint(equalTo: scrollView.heightAnchor, constant: 0.0).withPriority(.defaultLow),
        ])
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: continueButton.topAnchor),
        ])
        
        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor, constant: .standardSpacing),
            continueButton.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor, constant: -.standardSpacing),
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -.standardSpacing),
        ])
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if interactor.didTapCancel != nil {
            navigationController?.setNavigationBarHidden(false, animated: animated)
            navigationItem.leftBarButtonItem = UIBarButtonItem(title: localize(.cancel), style: .done, target: self, action: #selector(didTapCancel))
        } else {
            navigationController?.setNavigationBarHidden(true, animated: animated)
        }
    }
    
    @objc func didTapCancel() {
        interactor.didTapCancel?()
    }
    
    @objc func didTapOnlineServicesLink() {
        interactor.didTapOnlineServicesLink()
    }
    
    @objc func didTapPrimaryButton() {
        interactor.didTapPrimaryButton()
    }
}
