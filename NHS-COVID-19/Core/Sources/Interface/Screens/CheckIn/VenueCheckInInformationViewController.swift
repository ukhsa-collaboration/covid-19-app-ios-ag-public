//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import Localization
import UIKit

public protocol VenueCheckInInformationViewControllerInteracting {
    func didTapDismiss()
}

public class VenueCheckInInformationViewController: UIViewController {
    
    public typealias Interacting = VenueCheckInInformationViewControllerInteracting
    
    private let interactor: Interacting
    
    private var navigationBar: UIView {
        let navigationBar = UIView()
        let logoStrapline = LogoStrapline(.nhsBlue, style: .home)
        navigationBar.addFillingSubview(logoStrapline)
        return navigationBar
    }
    
    private var titleLabel: UIView {
        let label = UILabel()
        label.styleAsPageHeader()
        label.text = localize(.checkin_information_title)
        return label
    }
    
    private let howItWorksSection = InformationBox.information(
        title: localize(.checkin_information_how_it_works_section_title),
        body: [localize(.checkin_information_how_it_works_section_description)]
    )
    
    private let howItHelpsSection = InformationBox.information(
        title: localize(.checkin_information_how_it_helps_section_title),
        body: [localize(.checkin_information_how_it_helps_section_description)]
    )
    
    public init(interactor: Interacting) {
        self.interactor = interactor
        
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let view = self.view!
        view.styleAsScreenBackground(with: traitCollection)
        
        let content = [
            navigationBar,
            titleLabel,
            howItWorksSection,
            howItHelpsSection,
        ]
        let stackView = UIStackView(arrangedSubviews: content)
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = .doubleSpacing
        stackView.layoutMargins = .standard
        stackView.isLayoutMarginsRelativeArrangement = true
        
        let button = UIButton(type: .system)
        button.styleAsPrimary()
        button.setTitle(localize(.checkin_information_button_title), for: .normal)
        button.addTarget(self, action: #selector(didTapDismiss), for: .touchUpInside)
        
        let scrollView = UIScrollView()
        scrollView.addFillingSubview(stackView)
        
        view.addAutolayoutSubview(scrollView)
        view.addAutolayoutSubview(button)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor),
            scrollView.topAnchor.constraint(equalTo: view.layoutMarginsGuide.topAnchor),
            
            button.leadingAnchor.constraint(equalTo: view.layoutMarginsGuide.leadingAnchor),
            button.trailingAnchor.constraint(equalTo: view.layoutMarginsGuide.trailingAnchor),
            button.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: .standardSpacing),
            button.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -.standardSpacing),
        ])
    }
    
    @objc private func didTapDismiss() {
        interactor.didTapDismiss()
    }
}
