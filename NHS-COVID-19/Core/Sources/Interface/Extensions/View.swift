//
// Copyright © 2020 NHSX. All rights reserved.
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
    }
}

extension View {
    func linkify(_ key: StringLocalizationKey) -> some View {
        modifier(LinkButtonModifier(text: localize(key)))
    }
}
