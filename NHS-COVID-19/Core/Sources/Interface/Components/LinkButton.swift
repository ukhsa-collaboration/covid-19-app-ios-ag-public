//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import UIKit

public class LinkButton: UIControl {

    private var title: String
    private var accessoryImage: UIImage?
    private var externalLink: Bool
    private var action: (() -> Void)?

    public required init(
        title: String,
        accessoryImage: UIImage? = UIImage(.externalLink),
        externalLink: Bool = true,
        action: (() -> Void)? = nil
    ) {
        self.title = title
        self.accessoryImage = accessoryImage
        self.externalLink = externalLink
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
        if externalLink {
            accessibilityHint = localize(.link_accessibility_hint)
        }
        accessibilityLabel = title

        backgroundColor = .clear

        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.alignment = .center
        stackView.distribution = .fill
        stackView.spacing = .linkIconSpacing
        stackView.isUserInteractionEnabled = false
        addFillingSubview(stackView)

        let titleLabel = BaseLabel()
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
        titleLabel.setContentCompressionResistancePriority(.required, for: .horizontal)
        titleLabel.setContentHuggingPriority(.required, for: .horizontal)

        stackView.addArrangedSubview(titleLabel)

        var constraints = [heightAnchor.constraint(greaterThanOrEqualToConstant: .hitAreaMinHeight)]

        if let accessoryImage = accessoryImage {
            let externalLinkImageView = UIImageView(image: accessoryImage)
            externalLinkImageView.tintColor = UIColor(.nhsBlue)
            externalLinkImageView.adjustsImageSizeForAccessibilityContentSizeCategory = true
            externalLinkImageView.setContentCompressionResistancePriority(.required, for: .horizontal)

            let imageSize = externalLinkImageView.image!.size
            let aspectRatio = imageSize.height / imageSize.width
            stackView.addArrangedSubview(externalLinkImageView)

            constraints.append(contentsOf: [
                externalLinkImageView.heightAnchor.constraint(equalTo: externalLinkImageView.widthAnchor, multiplier: aspectRatio),
                externalLinkImageView.heightAnchor.constraint(lessThanOrEqualTo: titleLabel.heightAnchor),
            ])
        }

        NSLayoutConstraint.activate(constraints)

        stackView.addArrangedSubview(UIView())

        addTarget(self, action: #selector(touchUpInside))
    }

    @objc private func touchUpInside() {
        action?()
    }
}
