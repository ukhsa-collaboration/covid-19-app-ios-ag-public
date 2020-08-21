//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import SwiftUI

public struct NotIsolatingIndicator: View {
    @State private var animate = false
    @Environment(\.accessibilityReduceMotion) var reduceMotion
    
    fileprivate init() {}
    
    private func pulsatingCircle(delay: Double) -> some View {
        Circle()
            .foregroundColor(Color(.activeScanIndicator))
            .scaleEffect(animate ? 7 : 0)
            .opacity(Double(animate ? 0 : 1))
            .animation(
                Animation.easeOut(duration: 3)
                    .repeatForever(autoreverses: false).delay(delay)
            )
    }
    
    public var body: some View {
        VStack(alignment: .center, spacing: .standardSpacing) {
            ZStack(alignment: .center) {
                if self.reduceMotion {
                    Circle()
                        .foregroundColor(Color(.errorRed))
                        .opacity(0.05)
                } else {
                    self.pulsatingCircle(delay: 0).onAppear {
                        if !self.animate {
                            self.animate = true
                        }
                    }
                    self.pulsatingCircle(delay: 1)
                }
                
                ZStack {
                    Circle()
                        .foregroundColor(Color(.activeScanIndicator))
                        .overlay(Circle().stroke(Color(.lightSurface), lineWidth: 3))
                    Image(.tickImage).resizable()
                        .background(Color.clear)
                        .foregroundColor(Color(.lightSurface))
                        .padding(8)
                }.frame(width: 40, height: 40)
            }
            .frame(width: 75, height: 75, alignment: .center)
            
            Text(.risk_level_indicator_contact_tracing_active)
                .bold()
                .scaledFont(textStyle: .title3, size: 18)
                .foregroundColor(Color(.primaryText))
                .multilineTextAlignment(.center)
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(height: .appActivityIndicatorMinHeight)
        .accessibilityElement()
        .accessibility(label: Text(localize(.risk_level_indicator_contact_tracing_active)))
        .accessibility(addTraits: .isStaticText)
        .padding(EdgeInsets(top: .bigSpacing, leading: 0, bottom: .bigSpacing, trailing: 0))
    }
}

extension RiskLevelIndicator {
    static func makeNotIsolatingIndicator() -> AnyView {
        AnyView(NotIsolatingIndicator())
    }
}
