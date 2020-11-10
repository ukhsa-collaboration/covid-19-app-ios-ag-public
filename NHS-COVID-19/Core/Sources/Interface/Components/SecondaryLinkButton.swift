//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import UIKit

public class SecondaryLinkButton: UIControl {
    
    private var title: String
    private var action: (() -> Void)?
    
    public required init(
        title: String,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.action = action
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
        
        heightAnchor.constraint(greaterThanOrEqualToConstant: .hitAreaMinHeight).isActive = true
        
        let titleLabel = UILabel().styleAsHeading()
        titleLabel.textColor = UIColor(.nhsBlue)
        titleLabel.adjustsFontForContentSizeCategory = true
        titleLabel.numberOfLines = 0
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        titleLabel.setContentHuggingPriority(.required, for: .vertical)
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)
        titleLabel.attributedText = NSAttributedString(
            string: title,
            attributes: [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
            ]
        )
        
        let image = UIImage(.externalLink)
        let imageView = UIImageView(image: image).color(.nhsBlue)
        imageView.adjustsImageSizeForAccessibilityContentSizeCategory = true
        
        let aspectRatio = image.size.height / image.size.width
        imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor, multiplier: aspectRatio).isActive = true
        imageView.setContentCompressionResistancePriority(.required, for: .horizontal)
        imageView.setContentHuggingPriority(.required, for: .horizontal)
        imageView.setContentHuggingPriority(.required, for: .vertical)
        
        let stackView = UIStackView(arrangedSubviews: [titleLabel, imageView])
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = .linkIconSpacing
        stackView.isUserInteractionEnabled = false
        
        addAutolayoutSubview(stackView)
        
        NSLayoutConstraint.activate([
            stackView.heightAnchor.constraint(equalTo: heightAnchor, constant: -.doubleSpacing),
            stackView.centerYAnchor.constraint(equalTo: centerYAnchor),
            stackView.widthAnchor.constraint(lessThanOrEqualTo: widthAnchor, constant: -.doubleSpacing),
            stackView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.heightAnchor.constraint(lessThanOrEqualTo: titleLabel.heightAnchor),
        ])
        
        addTarget(self, action: #selector(touchUpInside))
    }
    
    @objc private func touchUpInside() {
        action?()
    }
}
