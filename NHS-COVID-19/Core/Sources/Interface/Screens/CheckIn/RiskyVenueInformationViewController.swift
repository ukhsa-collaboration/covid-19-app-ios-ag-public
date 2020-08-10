//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import UIKit

public protocol RiskyVenueInformationViewControllerInteracting {
    func goHome()
}

public class RiskyVenueInformationViewController: UIViewController {
    
    public typealias Interacting = RiskyVenueInformationViewControllerInteracting
    
    private var interactor: Interacting
    
    private var venueName: String
    private var checkInDate: Date
    
    private lazy var imageView: UIView = {
        let imageView = UIImageView(.coronaVirus)
        imageView.contentMode = .scaleAspectFit
        return imageView
    }()
    
    private lazy var titleLabel: UIView = {
        let titleLabel = UILabel()
        titleLabel.styleAsPageHeader()
        titleLabel.text = localize(.checkin_risky_venue_information_title(venue: venueName, date: checkInDate))
        titleLabel.textAlignment = .center
        return titleLabel
    }()
    
    private lazy var explanationLabel: UIView = {
        let explanationLabel = UILabel()
        explanationLabel.styleAsBody()
        explanationLabel.text = localize(.checkin_risky_venue_information_description)
        explanationLabel.textAlignment = .left
        return explanationLabel
    }()
    
    private lazy var button: UIView = {
        let actionButton = UIButton(type: .system)
        actionButton.styleAsPrimary()
        actionButton.setTitle(localize(.checkin_risky_venue_information_button_title), for: .normal)
        actionButton.addTarget(self, action: #selector(didTapActionButton), for: .touchUpInside)
        return actionButton
    }()
    
    public init(interactor: Interacting, venueName: String, checkInDate: Date) {
        self.interactor = interactor
        self.venueName = venueName
        self.checkInDate = checkInDate
        super.init(nibName: nil, bundle: nil)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(true, animated: true)
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let view = self.view!
        view.styleAsScreenBackground(with: traitCollection)
        
        let stackView = UIStackView(arrangedSubviews: [imageView, titleLabel, explanationLabel])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = .standardSpacing
        stackView.layoutMargins = .standard
        stackView.isLayoutMarginsRelativeArrangement = true
        
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
    
    @objc private func didTapActionButton() {
        interactor.goHome()
    }
    
}
