//
// Copyright © 2020 NHSX. All rights reserved.
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
    
    func setDynamicTextStyle(_ style: UIFont.TextStyle) {
        font = .preferredFont(forTextStyle: style)
        numberOfLines = 0
        adjustsFontForContentSizeCategory = true
    }
    
    func setBoldDynamicTextStyle(_ style: UIFont.TextStyle) {
        let boldFontDescriptor = UIFontDescriptor.preferredFontDescriptor(withTextStyle: style).withSymbolicTraits(.traitBold)
        font = UIFont(descriptor: boldFontDescriptor!, size: .zero)
        numberOfLines = 0
        adjustsFontForContentSizeCategory = true
    }
    
}
