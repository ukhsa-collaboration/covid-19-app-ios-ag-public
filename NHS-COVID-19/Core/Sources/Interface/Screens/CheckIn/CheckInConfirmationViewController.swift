//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol CheckInConfirmationViewControllerInteracting {
    func goHomeAfterCheckIn()
    func wrongCheckIn()
    func didTapVenueCheckinMoreInfoButton()
}

public class CheckInConfirmationViewController: UIViewController {
    
    public typealias Interacting = CheckInConfirmationViewControllerInteracting
    
    private var interactor: Interacting
    private var checkInDetail: CheckInDetail
    private var date: Date
    
    public init(interactor: Interacting, checkInDetail: CheckInDetail, date: Date) {
        self.interactor = interactor
        self.checkInDetail = checkInDetail
        self.date = date
        super.init(nibName: nil, bundle: nil)
    }
    
    let scrollView = UIScrollView()
    let wrongCheckInButton = UIButton()
    let goHomeButton = UIButton()
    
    private lazy var regularButtonConstraints = [
        goHomeButton.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor, constant: .standardSpacing),
        goHomeButton.bottomAnchor.constraint(equalTo: wrongCheckInButton.topAnchor, constant: -.standardSpacing),
        
        wrongCheckInButton.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor, constant: -.standardSpacing),
        wrongCheckInButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -.standardSpacing),
    ]
    
    private lazy var compactButtonConstraints = [
        goHomeButton.leadingAnchor.constraint(equalTo: wrongCheckInButton.trailingAnchor, constant: .doubleSpacing),
        goHomeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -.standardSpacing),
        
        wrongCheckInButton.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: .standardSpacing),
        wrongCheckInButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -.standardSpacing),
    ]
    
    private lazy var venueCheckinMoreInfoButton: UIView = {
        let venueCheckinMoreInfoButton = UIButton()
        let venueCheckinMoreInfoButtonTitle = localize(.checkin_camera_qrcode_scanner_help_button_accessibility_label)
        venueCheckinMoreInfoButton.styleAsLink()
        venueCheckinMoreInfoButton.setTitle(venueCheckinMoreInfoButtonTitle, for: .normal)
        venueCheckinMoreInfoButton.accessibilityLabel = localize(.checkin_camera_qrcode_scanner_help_button_accessibility_label)
        venueCheckinMoreInfoButton.addTarget(self, action: #selector(didTapVenueCheckinMoreInfoButton), for: .touchUpInside)
        return venueCheckinMoreInfoButton
    }()
    
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
        
        let checkImage = UIImage(.checkTick)
        let checkImageView = UIImageView(image: checkImage)
        checkImageView.contentMode = .scaleAspectFit
        checkImageView.tintColor = UIColor(.surface)
        
        let checkImageContainer = UIView()
        checkImageContainer.addAutolayoutSubview(checkImageView)
        checkImageContainer.backgroundColor = UIColor(.nhsButtonGreen)
        checkImageContainer.layer.cornerRadius = (checkImage.size.width / 2) + .bigSpacing
        
        NSLayoutConstraint.activate([
            checkImageView.leadingAnchor.constraint(equalTo: checkImageContainer.leadingAnchor, constant: .bigSpacing),
            checkImageView.trailingAnchor.constraint(equalTo: checkImageContainer.trailingAnchor, constant: -.bigSpacing),
            checkImageView.centerYAnchor.constraint(equalTo: checkImageContainer.centerYAnchor),
            checkImageContainer.heightAnchor.constraint(equalTo: checkImageContainer.widthAnchor),
        ])
        
        let checkInSuccessLabel = BaseLabel().styleAsSecondaryTitle().set(text: localize(.checkin_confirmation_title)).centralized()
        let venueNameLabel = BaseLabel().styleAsPageHeader().set(text: checkInDetail.venueName).centralized()
        let dateTimeLabel = BaseLabel().styleAsTertiaryTitle().set(text: localize(.checkin_confirmation_date(date: date))).centralized()
        let descriptionLabel = BaseLabel().styleAsBody().set(text: localize(.checkin_confirmation_explanation)).centralized()
        
        let stackViewContainerView = UIView()
        
        scrollView.addFillingSubview(stackViewContainerView)
        view.addAutolayoutSubview(scrollView)
        
        let stackView = UIStackView(arrangedSubviews: [checkImageContainer, checkInSuccessLabel, venueNameLabel, dateTimeLabel, descriptionLabel, venueCheckinMoreInfoButton])
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.layoutMargins = .standard
        stackView.spacing = .doubleSpacing
        
        stackView.setCustomSpacing(.standardSpacing, after: checkInSuccessLabel)
        stackView.setCustomSpacing(.halfSpacing, after: venueNameLabel)
        
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
        
        wrongCheckInButton.styleAsLink()
        wrongCheckInButton.setTitle(localize(.checkin_wrong_button_title), for: .normal)
        wrongCheckInButton.addTarget(self, action: #selector(didTapWrongCheckInButton), for: .touchUpInside)
        
        view.addAutolayoutSubview(wrongCheckInButton)
        
        goHomeButton.styleAsPrimary()
        goHomeButton.setTitle(localize(.checkin_confirmation_button_title), for: .normal)
        goHomeButton.addTarget(self, action: #selector(didTapGoHomeButton), for: .touchUpInside)
        
        view.addAutolayoutSubview(goHomeButton)
        
        NSLayoutConstraint.activate([
            scrollView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: goHomeButton.topAnchor, constant: -.standardSpacing),
            
            goHomeButton.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor, constant: -.standardSpacing),
            wrongCheckInButton.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor, constant: .standardSpacing),
            
            wrongCheckInButton.widthAnchor.constraint(equalTo: goHomeButton.widthAnchor),
        ])
        
        if traitCollection.verticalSizeClass == .compact {
            NSLayoutConstraint.activate(compactButtonConstraints)
        } else {
            NSLayoutConstraint.activate(regularButtonConstraints)
        }
    }
    
    override public func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        
        guard previousTraitCollection?.verticalSizeClass != traitCollection.verticalSizeClass else {
            return
        }
        
        if traitCollection.verticalSizeClass == .compact {
            NSLayoutConstraint.deactivate(regularButtonConstraints)
            NSLayoutConstraint.activate(compactButtonConstraints)
        } else {
            NSLayoutConstraint.deactivate(compactButtonConstraints)
            NSLayoutConstraint.activate(regularButtonConstraints)
        }
    }
    
    @objc private func didTapVenueCheckinMoreInfoButton() {
        interactor.didTapVenueCheckinMoreInfoButton()
    }
    
    @objc private func didTapGoHomeButton() {
        interactor.goHomeAfterCheckIn()
    }
    
    @objc private func didTapWrongCheckInButton() {
        checkInDetail.removeCurrentCheckIn()
        interactor.wrongCheckIn()
    }
    
}
