//
// Copyright © 2020 NHSX. All rights reserved.
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
                let descriptionLabel = UILabel()
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
    
    private lazy var whatsAQRCodeSection: UIView = {
        var content = [UIView]()
        
        let title = UILabel()
        title.styleAsTertiaryTitle()
        title.text = localize(.checkin_information_whats_a_qr_code_section_title)
        content.append(title)
        
        let descriptionLabel = UILabel()
        descriptionLabel.styleAsBody()
        descriptionLabel.text = localize(.checkin_information_whats_a_qr_code_section_description_new)
        content.append(descriptionLabel)
        
        let imageDescriptionLabel = UILabel()
        imageDescriptionLabel.styleAsBody()
        imageDescriptionLabel.text = localize(.qr_code_poster_description)
        
        let imageView = UIImageView(image: UIImage(.qrCodePoster))
        imageView.contentMode = .scaleAspectFit
        imageView.isAccessibilityElement = true
        imageView.accessibilityLabel = localize(.qr_code_poster_accessibility_label)
        
        let imageStackView = UIStackView(arrangedSubviews: [imageDescriptionLabel, imageView])
        imageStackView.axis = .vertical
        imageStackView.alignment = .leading
        imageStackView.spacing = .halfSpacing
        content.append(imageStackView)
        
        let imageDescriptionLabelWLS = UILabel()
        imageDescriptionLabelWLS.styleAsBody()
        imageDescriptionLabelWLS.text = localize(.qr_code_poster_description_wls)
        
        let imageViewWLS = UIImageView(image: UIImage(.qrCodePosterWales))
        imageViewWLS.contentMode = .scaleAspectFit
        imageViewWLS.isAccessibilityElement = true
        imageViewWLS.accessibilityLabel = localize(.qr_code_poster_accessibility_label_wls)
        
        let imageStackViewWLS = UIStackView(arrangedSubviews: [imageDescriptionLabelWLS, imageViewWLS])
        imageStackViewWLS.axis = .vertical
        imageStackViewWLS.alignment = .leading
        imageStackViewWLS.spacing = .halfSpacing
        content.append(imageStackViewWLS)
        
        let stackView = UIStackView(arrangedSubviews: content)
        stackView.axis = .vertical
        stackView.alignment = .leading
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
    
    private lazy var howItHelpsSection: UIView = {
        createSection(
            header: localize(.checkin_information_how_it_helps_section_title),
            description: localize(.checkin_information_how_it_helps_section_description)
        )
    }()
    
    private func createSection(header: String, description: String) -> UIView {
        var content = [UIView]()
        
        let title = UILabel()
        title.styleAsTertiaryTitle()
        title.text = header
        content.append(title)
        
        let descriptionLabel = UILabel()
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
    
    private func createImageSection(
        header: String,
        description: String,
        imageDescription: String,
        image: UIImage,
        imageAccessibilityLabel: String
    ) -> UIView {
        var content = [UIView]()
        
        let title = UILabel()
        title.styleAsTertiaryTitle()
        title.text = header
        content.append(title)
        
        let descriptionLabel = UILabel()
        descriptionLabel.styleAsBody()
        descriptionLabel.text = description
        content.append(descriptionLabel)
        
        let imageDescriptionLabel = UILabel()
        imageDescriptionLabel.styleAsBody()
        imageDescriptionLabel.text = description
        content.append(imageDescriptionLabel)
        
        let imageView = UIImageView(image: image)
        imageView.contentMode = .scaleAspectFit
        imageView.isAccessibilityElement = true
        imageView.accessibilityLabel = imageAccessibilityLabel
        content.append(imageView)
        
        let stackView = UIStackView(arrangedSubviews: content)
        stackView.axis = .vertical
        stackView.alignment = .leading
        stackView.spacing = .halfSpacing
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
            checkinDescriptionSection,
            helpScanningSection,
            whatsAQRCodeSection,
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
