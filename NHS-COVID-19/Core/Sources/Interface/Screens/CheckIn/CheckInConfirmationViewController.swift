//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol CheckInConfirmationViewControllerInteracting {
    func goHome()
    func wrongCheckIn()
}

public class CheckInConfirmationViewController: UIViewController {
    
    public typealias Interacting = CheckInConfirmationViewControllerInteracting
    
    private var interactor: Interacting
    private var checkInDetail: CheckInDetail
    private var date: Date
    
    public init(interactor: Interacting, checkInDetail: CheckInDetail, date: Date = Date()) {
        self.interactor = interactor
        self.checkInDetail = checkInDetail
        self.date = date
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
        
        view.styleAsScreenBackground(with: traitCollection)
        
        let checkImageView = UIImageView(.checkmark)
        checkImageView.contentMode = .scaleAspectFit
        checkImageView.tintColor = UIColor(.nhsButtonGreen)
        
        NSLayoutConstraint.activate([
            checkImageView.widthAnchor.constraint(equalToConstant: .confirmationIconImageSize),
            checkImageView.heightAnchor.constraint(equalToConstant: .confirmationIconImageSize),
        ])
        
        let titleLabel = UILabel()
        titleLabel.styleAsPageHeader()
        titleLabel.textAlignment = .center
        let title = localize(.checkin_confirmation_title(venue: checkInDetail.venueName, date: date))
        titleLabel.text = title
        
        let descriptionLabel = UILabel()
        descriptionLabel.styleAsBody()
        descriptionLabel.textAlignment = .center
        descriptionLabel.text = localize(.checkin_confirmation_explanation)
        descriptionLabel.numberOfLines = 0
        
        let scrollView = UIScrollView()
        
        let stackViewContainerView = UIView()
        
        view.addSubview(scrollView)
        scrollView.addFillingSubview(stackViewContainerView)
        
        view.addAutolayoutSubview(scrollView)
        
        let stackView = UIStackView(arrangedSubviews: [checkImageView, titleLabel, descriptionLabel])
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.layoutMargins = .standard
        stackView.spacing = .standardSpacing
        
        stackViewContainerView.addAutolayoutSubview(stackView)
        
        let stackViewContainerViewHeightConstraint = stackViewContainerView.heightAnchor.constraint(equalTo: scrollView.heightAnchor, constant: 0.0)
        stackViewContainerViewHeightConstraint.priority = .defaultLow
        
        NSLayoutConstraint.activate([
            stackViewContainerView.widthAnchor.constraint(equalTo: scrollView.widthAnchor, constant: 0.0),
            
            stackView.centerYAnchor.constraint(equalTo: stackViewContainerView.centerYAnchor, constant: 0.0),
            stackView.topAnchor.constraint(greaterThanOrEqualTo: stackViewContainerView.topAnchor),
            stackView.bottomAnchor.constraint(lessThanOrEqualTo: stackViewContainerView.bottomAnchor),
            stackView.leadingAnchor.constraint(equalTo: stackViewContainerView.leadingAnchor),
            stackView.trailingAnchor.constraint(equalTo: stackViewContainerView.trailingAnchor),
            
            stackViewContainerViewHeightConstraint,
        ])
        
        let wrongCheckInButton = UIButton()
        wrongCheckInButton.setTitle(localize(.checkin_wrong_button_title), for: .normal)
        wrongCheckInButton.setTitleColor(UIColor(.nhsBlue), for: .normal)
        wrongCheckInButton.titleLabel?.setDynamicTextStyle(.headline)
        wrongCheckInButton.titleLabel?.textAlignment = .center
        
        wrongCheckInButton.addTarget(self, action: #selector(didTapWrongCheckInButton), for: .touchUpInside)
        
        view.addAutolayoutSubview(wrongCheckInButton)
        
        NSLayoutConstraint.activate([
            wrongCheckInButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .standardSpacing),
            wrongCheckInButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.standardSpacing),
            wrongCheckInButton.bottomAnchor.constraint(equalTo: view.layoutMarginsGuide.bottomAnchor, constant: -.standardSpacing),
            wrongCheckInButton.heightAnchor.constraint(greaterThanOrEqualToConstant: .buttonMinimumHeight),
            wrongCheckInButton.heightAnchor.constraint(greaterThanOrEqualTo: wrongCheckInButton.titleLabel!.heightAnchor, constant: .standardSpacing),
        ])
        
        let goHomeButton = UIButton()
        goHomeButton.styleAsPrimary()
        goHomeButton.setTitle(localize(.checkin_confirmation_button_title), for: .normal)
        goHomeButton.addTarget(self, action: #selector(didTapGoHomeButton), for: .touchUpInside)
        
        view.addAutolayoutSubview(goHomeButton)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: goHomeButton.topAnchor, constant: -.standardSpacing),
        ])
        
        NSLayoutConstraint.activate([
            goHomeButton.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: .standardSpacing),
            goHomeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -.standardSpacing),
            goHomeButton.bottomAnchor.constraint(equalTo: wrongCheckInButton.topAnchor, constant: -.standardSpacing),
        ])
    }
    
    @objc private func didTapGoHomeButton() {
        interactor.goHome()
    }
    
    @objc private func didTapWrongCheckInButton() {
        checkInDetail.removeCurrentCheckIn()
        interactor.wrongCheckIn()
    }
    
}
