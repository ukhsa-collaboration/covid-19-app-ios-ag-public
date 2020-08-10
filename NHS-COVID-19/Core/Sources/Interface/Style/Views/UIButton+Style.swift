//
// Copyright © 2020 NHSX. All rights reserved.
//

import UIKit

extension UIButton {
    
    public func styleAsPrimary() {
        backgroundColor = UIColor(.nhsBlue)
        layer.cornerRadius = .buttonCornerRadius
        tintColor = UIColor(.primaryButtonLabel)
        titleLabel?.setDynamicTextStyle(.headline)
        titleLabel?.textAlignment = .center
        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: .buttonMinimumHeight),
            heightAnchor.constraint(greaterThanOrEqualTo: titleLabel!.heightAnchor, multiplier: 1, constant: .standardSpacing),
        ])
    }
    
    public func styleAsSecondary() {
        setTitleColor(UIColor(.nhsBlue), for: .normal)
        titleLabel?.setDynamicTextStyle(.headline)
        titleLabel?.textAlignment = .center
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: .buttonMinimumHeight),
            heightAnchor.constraint(greaterThanOrEqualTo: titleLabel!.heightAnchor, constant: .standardSpacing),
        ])
    }
    
    public func styleAsLink(text: String) {
        titleLabel?.attributedText = NSAttributedString(
            string: text,
            attributes: [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
                .font: UIFont.preferredFont(forTextStyle: .headline),
                .foregroundColor: UIColor(.nhsBlue),
            ]
        )
        setTitleColor(UIColor(.nhsBlue), for: .normal)
        titleLabel?.adjustsFontForContentSizeCategory = true
        titleLabel?.numberOfLines = 0
        titleLabel?.setContentCompressionResistancePriority(.almostRequest, for: .horizontal)
    }
    
    public func styleAsPlain(with color: UIColor) {
        setTitleColor(color, for: .normal)
        titleLabel?.setDynamicTextStyle(.body)
        titleLabel?.textAlignment = .center
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: .buttonMinimumHeight),
            heightAnchor.constraint(greaterThanOrEqualTo: titleLabel!.heightAnchor, constant: .standardSpacing),
        ])
    }
}
