//
// Copyright © 2021 DHSC. All rights reserved.
//

import SwiftUI

/**
 Ensure the element aligns with the first line of the text by getting it
 to center align with an invisible character which scales the same way
 when the dynamic text settings change
 */
private struct TextBaselineAlignmentModifier: ViewModifier {
    let font: Font
    
    func body(content: Content) -> some View {
        ZStack(alignment: .center) {
            Text("\u{00A0}")
                .font(font)
                .frame(width: 0)
                .accessibility(hidden: true)
            content
        }
    }
}

extension View {
    /// Aligns an element with the first line of the text inside `HStack`.
    ///
    /// This method should be used for a subview (e.g. bullet point, icon, etc.)
    /// inside `HStack` with any needed alignment.
    public func textBaselineAligned(font: Font) -> some View {
        modifier(TextBaselineAlignmentModifier(font: font))
    }
}
