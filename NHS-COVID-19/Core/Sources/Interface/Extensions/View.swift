//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import SwiftUI

public struct LinkButtonModifier: ViewModifier {
    var text: String
    
    public func body(content: Content) -> some View {
        content
            .accessibilityElement()
            .accessibility(addTraits: .isLink)
            .accessibility(label: Text(text))
            .accessibility(hint: Text(localize(.link_accessibility_hint)))
    }
}

extension View {
    func linkify(_ key: StringLocalizableKey) -> some View {
        modifier(LinkButtonModifier(text: localize(key)))
    }
    
    func linkify(_ accessibilityLabelText: String) -> some View {
        modifier(LinkButtonModifier(text: accessibilityLabelText))
    }
}

struct ScaledFont: ViewModifier {
    @Environment(\.sizeCategory) var sizeCategory
    var name: String
    var size: CGFloat
    
    func body(content: Content) -> some View {
        let scaledSize = UIFontMetrics.default.scaledValue(for: size)
        return content.font(.custom(name, size: scaledSize))
    }
}

extension View {
    func scaledFont(name: String, size: CGFloat) -> some View {
        modifier(ScaledFont(name: name, size: size))
    }
    
    func scaledFont(textStyle: UIFont.TextStyle, size: CGFloat) -> some View {
        let uiFont = UIFont.preferredFont(forTextStyle: textStyle)
        return scaledFont(name: uiFont.familyName, size: size)
    }
}
