//
// Copyright © 2021 DHSC. All rights reserved.
//

import UIKit

extension UIButton {
    
    public func styleAsPrimary() {
        backgroundColor = UIColor(.nhsBlue)
        layer.cornerRadius = .buttonCornerRadius
        tintColor = UIColor(.primaryButtonLabel)
        titleLabel?.setDynamicTextStyle(.headline)
        titleLabel?.textAlignment = .center
        
        // for .custom buttons, tintColor has no effect on the title so set it manually
        if buttonType == .custom {
            setTitleColor(tintColor, for: .normal)
        }
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: .buttonMinimumHeight),
            heightAnchor.constraint(greaterThanOrEqualTo: titleLabel!.heightAnchor, constant: .standardSpacing),
            widthAnchor.constraint(equalTo: titleLabel!.widthAnchor, constant: .standardSpacing),
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
    
    public func styleAsLink() {
        setTitleColor(UIColor(.nhsBlue), for: .normal)
        titleLabel?.setDynamicTextStyle(.headline)
        titleLabel?.textAlignment = .center
        titleLabel?.attributedText = NSAttributedString(
            string: " ",
            attributes: [
                .underlineStyle: NSUnderlineStyle.single.rawValue,
            ]
        )
        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: .buttonMinimumHeight),
            heightAnchor.constraint(greaterThanOrEqualTo: titleLabel!.heightAnchor, multiplier: 1, constant: .standardSpacing),
        ])
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
    
    public func styleAsDestructive() {
        setTitleColor(UIColor(.errorRed), for: .normal)
        titleLabel?.setBoldDynamicTextStyle(.body)
        titleLabel?.textAlignment = .center
        
        NSLayoutConstraint.activate([
            heightAnchor.constraint(greaterThanOrEqualToConstant: .buttonMinimumHeight),
            heightAnchor.constraint(greaterThanOrEqualTo: titleLabel!.heightAnchor, constant: .standardSpacing),
        ])
    }
}
