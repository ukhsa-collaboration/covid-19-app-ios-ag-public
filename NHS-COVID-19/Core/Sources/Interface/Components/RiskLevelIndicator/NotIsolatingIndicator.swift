//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import SwiftUI

public struct NotIsolatingIndicator: View {
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    fileprivate init() {}
    
    private let badgeSize: CGFloat = 40
    
    public var body: some View {
        VStack(alignment: .center, spacing: .doubleSpacing) {
            ZStack {
                if self.reduceMotion {
                    Circle()
                        .foregroundColor(Color(.errorRed))
                        .opacity(0.05)
                } else {
                    PulsatingCircle(delay: 0, initialDiameter: badgeSize, color: Color(.activeScanIndicator))
                    PulsatingCircle(delay: 1, initialDiameter: badgeSize, color: Color(.activeScanIndicator))
                }
                
                Circle()
                    .foregroundColor(Color(.activeScanIndicator))
                    .overlay(Circle().stroke(Color(.lightSurface), lineWidth: 3))
                Image(.tickImage).resizable()
                    .background(Color.clear)
                    .foregroundColor(Color(.lightSurface))
                    .padding(8)
            }
            .frame(width: badgeSize, height: badgeSize)
            
            Text(.risk_level_indicator_contact_tracing_active)
                .bold()
                .scaledFont(textStyle: .title3, size: 18)
                .foregroundColor(Color(.primaryText))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(height: .appActivityIndicatorMinHeight)
        .accessibilityElement()
        .contentShape(Rectangle())
        .accessibility(label: Text(localize(.risk_level_indicator_contact_tracing_active)))
        .accessibility(addTraits: .isStaticText)
        .padding(EdgeInsets(top: .bigSpacing, leading: 0, bottom: .bigSpacing, trailing: 0))
        .environment(\.locale, Locale(identifier: currentLanguageCode()))
    }
}

extension RiskLevelIndicator {
    static func makeNotIsolatingIndicator() -> AnyView {
        AnyView(NotIsolatingIndicator())
    }
}
