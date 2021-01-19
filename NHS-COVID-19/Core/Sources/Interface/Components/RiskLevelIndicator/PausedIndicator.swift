//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import SwiftUI

public struct PausedIndicator: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    fileprivate init() {}
    
    public var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke()
                    .foregroundColor(Color(.warningIcon))
                    .frame(width: 82, height: 82)
                
                Circle()
                    .stroke(lineWidth: 0.5)
                    .foregroundColor(Color(.warningIcon))
                    .frame(width: 82, height: 82)
                    .scaleEffect(2)
                
                ZStack {
                    Circle()
                        .foregroundColor(Color(.warningIcon))
                    Image(.warningIcon)
                        .background(Color.clear)
                }
                .frame(width: 62, height: 62)
            }
            
            Text(.risk_level_indicator_contact_tracing_not_active)
                .font(.body)
                .foregroundColor(Color(.primaryText))
                .fixedSize(horizontal: false, vertical: true)
        }
        .contentShape(Rectangle())
        .accessibility(label: Text(localize(.risk_level_indicator_contact_tracing_not_active)))
        .accessibility(addTraits: .isImage)
        .frame(height: 280)
        .environment(\.locale, Locale(identifier: currentLanguageCode()))
    }
}

extension RiskLevelIndicator {
    static func makePausedIndicator() -> AnyView {
        AnyView(PausedIndicator())
    }
}
