//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Localization
import UIKit

public protocol PositiveTestResultNoIsolationViewControllerInteracting {
    func didTapOnlineServicesLink()
    func didTapContinue()
}

public class PositiveTestResultNoIsolationViewController: UIViewController {
    private var shareKeysCancellable = [AnyCancellable]()
    
    public typealias Interacting = PositiveTestResultNoIsolationViewControllerInteracting
    
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
        
        let titleLabel = UILabel()
        titleLabel.text = localize(.end_of_isolation_positive_text_no_isolation_title)
        titleLabel.styleAsPageHeader()
        titleLabel.textAlignment = .center
        
        let infobox = InformationBox.indication.warning(localize(.end_of_isolation_isolate_if_have_symptom_warning))
        
        let explanationLabel = UILabel()
        explanationLabel.text = localize(.end_of_isolation_further_advice_visit)
        explanationLabel.styleAsBody()
        
        let onlineServicesLink = LinkButton(
            title: localize(.end_of_isolation_online_services_link),
            textAlignment: .left
        )
        onlineServicesLink.addTarget(self, action: #selector(didTapOnlineServicesLink), for: .touchUpInside)
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, infobox, explanationLabel, onlineServicesLink])
        stackView.axis = .vertical
        stackView.spacing = .standardSpacing
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .standard
        
        let continueButton = UIButton()
        continueButton.setTitle(localize(.positive_test_results_continue), for: .normal)
        continueButton.styleAsPrimary()
        continueButton.setContentHuggingPriority(.defaultLow, for: .horizontal)
        continueButton.addTarget(self, action: #selector(didTapContinue), for: .touchUpInside)
        
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
            scrollView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: continueButton.topAnchor),
        ])
        
        NSLayoutConstraint.activate([
            continueButton.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: .standardSpacing),
            continueButton.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -.standardSpacing),
            continueButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -.standardSpacing),
        ])
    }
    
    @objc func didTapOnlineServicesLink() {
        interactor.didTapOnlineServicesLink()
    }
    
    @objc func didTapContinue() {
        interactor.didTapContinue()
    }
}
