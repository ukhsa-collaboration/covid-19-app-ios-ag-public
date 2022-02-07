//
// Copyright © 2021 DHSC. All rights reserved.
//

import UIKit

extension UILabel {
    @discardableResult
    public func styleAsPageHeader() -> Self {
        textColor = UIColor(.primaryText)
        setBoldDynamicTextStyle(.title1)
        accessibilityTraits = .header
        return self
    }
    
    @discardableResult
    public func styleAsBody() -> Self {
        textColor = UIColor(.primaryText)
        setDynamicTextStyle(.body)
        return self
    }
    
    @discardableResult
    public func styleAsBoldBody() -> Self {
        textColor = UIColor(.primaryText)
        setBoldDynamicTextStyle(.body)
        return self
    }
    
    @discardableResult
    public func styleAsSecondaryBody() -> Self {
        textColor = UIColor(.secondaryText)
        setDynamicTextStyle(.body)
        return self
    }
    
    @discardableResult
    public func styleAsError() -> Self {
        textColor = UIColor(.errorRed)
        setBoldDynamicTextStyle(.body)
        return self
    }
    
    @discardableResult
    public func styleAsErrorHeading() -> Self {
        textColor = UIColor(.errorRed)
        setDynamicTextStyle(.headline)
        accessibilityTraits = .header
        return self
    }
    
    @discardableResult
    public func styleAsHeading() -> Self {
        textColor = UIColor(.primaryText)
        setDynamicTextStyle(.headline)
        accessibilityTraits = .header
        return self
    }
    
    @discardableResult
    public func styleSubHeading() -> Self {
        textColor = UIColor(.primaryText)
        setDynamicTextStyle(.subheadline)
        accessibilityTraits = .header
        return self
    }
    
    @discardableResult
    public func styleAsSecondaryTitle() -> Self {
        textColor = UIColor(.primaryText)
        setDynamicTextStyle(.title2)
        accessibilityTraits = .header
        return self
    }
    
    @discardableResult
    public func styleAsTertiaryTitle() -> Self {
        textColor = UIColor(.primaryText)
        setBoldDynamicTextStyle(.title3)
        accessibilityTraits = .header
        return self
    }
    
    @discardableResult
    public func styleAsSectionHeader() -> Self {
        textColor = UIColor(.sectionHeaderText)
        accessibilityTraits = .header
        setDynamicTextStyle(.body)
        return self
    }
    
    @discardableResult
    public func styleAsCaption() -> Self {
        textColor = UIColor(.secondaryText)
        setDynamicTextStyle(.caption1)
        return self
    }
    
    @discardableResult
    public func set(text: String?) -> Self {
        self.text = text
        return self
    }
    
    @discardableResult
    public func centralized() -> Self {
        textAlignment = .center
        return self
    }
    
    @discardableResult
    public func leadingAligned() -> Self {
        textAlignment = .leading
        return self
    }
    
    func setDynamicTextStyle(_ style: UIFont.TextStyle, numberOfLines: Int = 0) {
        font = .preferredFont(forTextStyle: style)
        self.numberOfLines = numberOfLines
        adjustsFontForContentSizeCategory = true
    }
    
    func setBoldDynamicTextStyle(_ style: UIFont.TextStyle) {
        let boldFontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style).withSymbolicTraits(.traitBold)
        font = UIFont(descriptor: boldFontDescriptor!, size: .zero)
        numberOfLines = 0
        adjustsFontForContentSizeCategory = true
    }
    
}

extension UILabel {
    
    @discardableResult
    func accessibilitySpellOut() -> Self {
        if let text = self.text {
            accessibilityAttributedLabel = NSAttributedString(string: text, attributes: [.accessibilitySpeechSpellOut: true])
        }
        return self
    }
    
    @discardableResult
    func formatAsPostcode() -> Self {
        if let text = self.text,
            text.count >= 5,
            !text.contains(" ") {
            self.text = "\(text.prefix(text.count - 3)) \(text.suffix(3))"
        }
        return self
    }
}
