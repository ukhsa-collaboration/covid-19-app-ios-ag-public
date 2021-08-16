//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation
import Localization
import UIKit

public protocol VenueCheckInInformationViewControllerInteracting {
    func didTapDismiss()
}

public class VenueCheckInInformationViewController: UIViewController {
    
    public typealias Interacting = VenueCheckInInformationViewControllerInteracting
    
    private let interactor: Interacting
    
    private lazy var checkinDescriptionSection: UIView = {
        var content = [UIView]()
        
        localizeAndSplit(.checkin_information_description)
            .forEach {
                let descriptionLabel = BaseLabel()
                descriptionLabel.styleAsBody()
                descriptionLabel.text = String($0)
                content.append(descriptionLabel)
            }
        
        let stackView = UIStackView(arrangedSubviews: content)
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = .standardSpacing
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .inner
        
        return stackView
    }()
    
    private lazy var helpScanningSection: UIView = {
        createSection(
            header: localize(.checkin_information_help_scanning_section_title),
            description: localize(.checkin_information_help_scanning_section_description)
        )
    }()
    
    private lazy var howToScanSection: UIView = {
        createSection(
            header: localize(.checkin_information_how_to_scan_section_title),
            description: localize(.checkin_information_how_to_scan_section_description)
        )
    }()
    
    private lazy var whatsAQRCodeSection: UIView = {
        let stackView = UIStackView(
            arrangedSubviews: [
                BaseLabel()
                    .styleAsTertiaryTitle()
                    .set(text: localize(.checkin_information_whats_a_qr_code_section_title)),
                BaseLabel()
                    .styleAsBody()
                    .set(text: localize(.checkin_information_whats_a_qr_code_section_description)),
                BaseLabel()
                    .styleAsTertiaryTitle()
                    .set(text: localize(.checkin_information_official_nhs_qr_codes_title)),
                createPosterStack(
                    posterImage: UIImage(.qrCodePosterHospitality),
                    labelText: localize(.qr_code_poster_description_hospitality),
                    accessibilityLabel: localize(.qr_code_poster_accessibility_label_hospitality)
                ),
                createPosterStack(
                    posterImage: UIImage(.qrCodePosterHospitalityWales),
                    labelText: localize(.qr_code_poster_wales_description_hospitality),
                    accessibilityLabel: localize(.qr_code_poster_wales_accessibility_label_hospitality)
                ),
                createPosterStack(
                    posterImage: UIImage(.qrCodePoster),
                    labelText: localize(.qr_code_poster_description),
                    accessibilityLabel: localize(.qr_code_poster_accessibility_label)
                ),
                createPosterStack(
                    posterImage: UIImage(.qrCodePosterWales),
                    labelText: localize(.qr_code_poster_wales_description),
                    accessibilityLabel: localize(.qr_code_poster_wales_accessibility_label)
                ),
            ])
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.spacing = .standardSpacing
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .inner
        
        return stackView
    }()
    
    private lazy var howItWorksSection: UIView = {
        createSection(
            header: localize(.checkin_information_how_it_works_section_title),
            description: localize(.checkin_information_how_it_works_section_description)
        )
    }()
    
    private func createPosterStack(posterImage: UIImage, labelText: String, accessibilityLabel: String) -> UIView {
        let label = BaseLabel()
        label.styleAsBody()
        label.text = labelText
        
        let poster = UIImageView(image: posterImage)
        poster.contentMode = .scaleAspectFit
        poster.isAccessibilityElement = true
        poster.accessibilityLabel = accessibilityLabel
        poster.accessibilityTraits.remove(.image)
        
        let posterStack = UIStackView(arrangedSubviews: [label, poster])
        posterStack.axis = .vertical
        posterStack.alignment = .fill
        posterStack.spacing = .halfSpacing
        
        return posterStack
    }
    
    private func createSection(header: String, description: String) -> UIView {
        var content = [UIView]()
        
        let title = BaseLabel()
        title.styleAsTertiaryTitle()
        title.text = header
        content.append(title)
        
        let descriptionLabel = BaseLabel()
        descriptionLabel.styleAsBody()
        descriptionLabel.text = description
        content.append(descriptionLabel)
        
        let stackView = UIStackView(arrangedSubviews: content)
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = .standardSpacing
        stackView.isLayoutMarginsRelativeArrangement = true
        stackView.layoutMargins = .inner
        
        return stackView
    }
    
    public init(interactor: Interacting) {
        self.interactor = interactor
        
        super.init(nibName: nil, bundle: nil)
        
        title = localize(.checkin_information_title_new)
    }
    
    public required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        
        let view = self.view!
        view.styleAsScreenBackground(with: traitCollection)
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: localize(.cancel), style: .plain, target: self, action: #selector(didTapDismiss))
        
        let content = [
            howItWorksSection,
            howToScanSection,
            helpScanningSection,
            whatsAQRCodeSection,
        ]
        let stackView = UIStackView(arrangedSubviews: content)
        stackView.axis = .vertical
        stackView.alignment = .fill
        stackView.distribution = .fill
        stackView.spacing = .doubleSpacing
        stackView.layoutMargins = .standard
        stackView.isLayoutMarginsRelativeArrangement = true
        
        let scrollView = UIScrollView()
        scrollView.addFillingSubview(stackView)
        
        view.addFillingSubview(scrollView)
        
        NSLayoutConstraint.activate([
            stackView.widthAnchor.constraint(equalTo: view.widthAnchor),
        ])
    }
    
    @objc private func didTapDismiss() {
        interactor.didTapDismiss()
    }
}
