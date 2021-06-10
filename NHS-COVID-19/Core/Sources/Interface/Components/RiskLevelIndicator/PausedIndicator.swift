//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import SwiftUI

public struct PausedIndicator: View {
    private let turnBackOnTapAction: () -> Void
    
    fileprivate init(turnBackOnTapAction: @escaping () -> Void) {
        self.turnBackOnTapAction = turnBackOnTapAction
    }
    
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
            
            Button.underlined(
                text: localize(.risk_level_indicator_contact_tracing_turn_back_on_button),
                action: turnBackOnTapAction
            )
            .foregroundColor(Color(.nhsLightBlue))
            .font(Font.headline.weight(.bold))
            .padding(.hairSpacing)
        }
        .contentShape(Rectangle())
        .accessibilityElement(children: .contain)
        .frame(height: 280)
        .environment(\.locale, Locale(identifier: currentLocaleIdentifier()))
    }
}

extension RiskLevelIndicator {
    static func makePausedIndicator(turnBackOnTapAction: @escaping () -> Void) -> AnyView {
        AnyView(PausedIndicator(turnBackOnTapAction: turnBackOnTapAction))
    }
}
