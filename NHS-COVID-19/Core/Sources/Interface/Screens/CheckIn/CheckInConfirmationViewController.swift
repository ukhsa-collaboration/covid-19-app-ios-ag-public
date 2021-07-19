//
// Copyright © 2021 DHSC. All rights reserved.
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
    
    private let scrollView = UIScrollView()
    private let wrongCheckInButton = UIButton()
    private let goHomeButton = UIButton()
    private var descriptionLabel: UILabel!
    private let checkImageView = UIImageView()
    private var checkImages = [UIImage]()
    
    private lazy var regularButtonConstraints = [
        goHomeButton.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor, constant: .standardSpacing),
        goHomeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -.standardSpacing),
        
        wrongCheckInButton.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor, constant: -.standardSpacing),
        wrongCheckInButton.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: .standardSpacing),
        wrongCheckInButton.bottomAnchor.constraint(equalTo: goHomeButton.topAnchor, constant: -.standardSpacing),
    ]
    
    private lazy var compactButtonConstraints = [
        goHomeButton.leadingAnchor.constraint(equalTo: wrongCheckInButton.trailingAnchor, constant: .doubleSpacing),
        goHomeButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -.standardSpacing),
        
        wrongCheckInButton.topAnchor.constraint(equalTo: scrollView.bottomAnchor, constant: .standardSpacing),
        wrongCheckInButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -.standardSpacing),
    ]
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        navigationController?.setNavigationBarHidden(true, animated: true)
        
        // show different assets depending on whether we're in dark mode or not
        let isDarkMode = traitCollection.userInterfaceStyle == .dark
        let imageIndexRange = {
            isDarkMode ? (004 ... 083) : (2004 ... 2083)
        }()
        let imageNameFormat = {
            isDarkMode ? "tick_final_dark-mode%03d" : "tick-final_%d"
        }()
        
        if UIAccessibility.isReduceMotionEnabled {
            checkImageView.image = UIImage(named: String(format: imageNameFormat, imageIndexRange.upperBound)) // just show the final frame
        } else if checkImages.isEmpty {
            
            // load images on a background queue
            DispatchQueue.global(qos: .userInitiated).async {
                
                self.checkImages.append(contentsOf: imageIndexRange.compactMap {
                    if ($0 % 2) == 0 {
                        return nil
                    }
                    return UIImage(named: String(format: imageNameFormat, $0))
                })
                
                // start the animation on the main queue
                DispatchQueue.main.async {
                    
                    self.checkImageView.image = self.checkImages.last
                    self.checkImageView.animationImages = self.checkImages
                    self.checkImageView.animationRepeatCount = 1
                    self.checkImageView.startAnimating()
                    
                    // play the success haptic
                    let feebackGenerator = UINotificationFeedbackGenerator()
                    feebackGenerator.notificationOccurred(.success)
                }
            }
        }
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        view.styleAsScreenBackground(with: traitCollection)
        
        NSLayoutConstraint.activate([
            checkImageView.widthAnchor.constraint(equalToConstant: 300),
            checkImageView.heightAnchor.constraint(equalTo: checkImageView.widthAnchor),
        ])
        checkImageView.contentMode = .scaleAspectFit
        checkImageView.tintColor = UIColor(.surface)
        
        let venueNameLabel = BaseLabel().styleAsBody().centralized()
        let dateTimeLabel = BaseLabel().styleAsTertiaryTitle().set(text: localize(.checkin_confirmation_date(date: date))).centralized()
        
        // build an attributed string to display the thank you text plus the venue name
        venueNameLabel.attributedText = checkInThanksAttributedString(venue: checkInDetail.venueName)
        
        descriptionLabel = BaseLabel().styleAsBody().set(text: localize(.checkin_confirmation_simplified_explanation)).centralized()
        
        // Build a vertical stack view and add to the scroll view to hold the image and text
        let stackViewContainerView = UIView()
        scrollView.addFillingSubview(stackViewContainerView)
        view.addAutolayoutSubview(scrollView)
        
        let stackView = UIStackView(arrangedSubviews: [checkImageView, venueNameLabel, dateTimeLabel, descriptionLabel])
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.axis = .vertical
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.layoutMargins = .standard
        stackView.spacing = .doubleSpacing
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
        
        // Wrong check in?
        wrongCheckInButton.styleAsLink()
        wrongCheckInButton.setTitle(localize(.checkin_cancel_checkin_button_title), for: .normal)
        wrongCheckInButton.addTarget(self, action: #selector(didTapWrongCheckInButton), for: .touchUpInside)
        view.addAutolayoutSubview(wrongCheckInButton)
        
        // Back to home
        goHomeButton.styleAsPrimary()
        goHomeButton.setTitle(localize(.checkin_confirmation_button_title), for: .normal)
        goHomeButton.addTarget(self, action: #selector(didTapGoHomeButton), for: .touchUpInside)
        view.addAutolayoutSubview(goHomeButton)
        
        NSLayoutConstraint.activate([
            
            // scroll view aligns with the container and extends down to the top of the wrong check in? button
            scrollView.leadingAnchor.constraint(equalTo: view.readableContentGuide.leadingAnchor),
            scrollView.trailingAnchor.constraint(equalTo: view.readableContentGuide.trailingAnchor),
            scrollView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            scrollView.bottomAnchor.constraint(equalTo: wrongCheckInButton.topAnchor, constant: -.standardSpacing),
            
            // Wrong check in? and Back to home buttons are part of the main view and appear below the scroll view
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
    
    private func checkInThanksAttributedString(venue: String) -> NSAttributedString {
        let thanksText = localize(.checkin_confirmation_thankyou(venue: venue))
        let attributedThanksText = NSMutableAttributedString(
            string: thanksText,
            attributes: [
                .font: UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title3).withSymbolicTraits(.traitBold)!, size: .zero),
                .foregroundColor: UIColor(.primaryText),
            ]
        )
        if let venueRange = thanksText.range(of: checkInDetail.venueName) {
            attributedThanksText.setAttributes([
                .font: UIFont(descriptor: UIFontDescriptor.preferredFontDescriptor(withTextStyle: .title2).withSymbolicTraits(.traitBold)!, size: .zero),
                .foregroundColor: UIColor(.primaryText),
            ], range: NSRange(venueRange, in: thanksText))
        }
        return attributedThanksText
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
