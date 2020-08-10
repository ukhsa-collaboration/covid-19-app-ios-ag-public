//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import UIKit

public class LinkButton: UIControl {
    
    private var title: String
    private var textAlignment: NSTextAlignment
    private var accessoryImage: UIImage?
    
    public required init(title: String, textAlignment: NSTextAlignment = NSTextAlignment.natural, accessoryImage: UIImage? = UIImage(.externalLink)) {
        self.title = title
        self.textAlignment = textAlignment
        self.accessoryImage = accessoryImage
        super.init(frame: .zero)
        
        setUp()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUp() {
        isAccessibilityElement = true
        accessibilityTraits = .link
        accessibilityHint = localize(.link_accessibility_hint)
        accessibilityLabel = title
        
        backgroundColor = .clear
        
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = .linkIconSpacing
        stackView.isUserInteractionEnabled = false
        addFillingSubview(stackView)
        
        let titleLabel = UILabel()
        titleLabel.attributedText = NSAttributedString(
            string: title,
            attributes: [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .font: UIFont.preferredFont(forTextStyle: .headline),
                .foregroundColor: UIColor(.nhsBlue),
            ]
        )
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 0
        titleLabel.textAlignment = textAlignment
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        
        stackView.addArrangedSubview(titleLabel)
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: .hitAreaMinHeight),
        ])
        
        if let accessoryImage = accessoryImage {
            let externalLinkImageView = UIImageView(image: accessoryImage)
            externalLinkImageView.tintColor = UIColor(.nhsBlue)
            externalLinkImageView.adjustsImageSizeForAccessibilityContentSizeCategory = true
            externalLinkImageView.setContentHuggingPriority(.required, for: .horizontal)
            externalLinkImageView.setContentCompressionResistancePriority(.required, for: .horizontal)
            
            let imageSize = externalLinkImageView.image!.size
            let aspectRatio = imageSize.height / imageSize.width
            stackView.addArrangedSubview(externalLinkImageView)
            
            NSLayoutConstraint.activate([
                externalLinkImageView.heightAnchor.constraint(equalTo: externalLinkImageView.widthAnchor, multiplier: aspectRatio),
                externalLinkImageView.heightAnchor.constraint(lessThanOrEqualTo: titleLabel.heightAnchor),
            ])
        }
        
        stackView.addArrangedSubview(UIView())
    }
}
