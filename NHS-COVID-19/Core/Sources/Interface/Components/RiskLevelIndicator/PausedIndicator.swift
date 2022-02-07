//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import SwiftUI

public struct PausedIndicator: View {
    private let action: () -> Void
    let message: String
    let buttonTitle: String
    
    fileprivate init(action: @escaping () -> Void, message: String, buttonTitle: String) {
        self.action = action
        self.message = message
        self.buttonTitle = buttonTitle
    }
    
    public var body: some View {
        VStack {
            ZStack {
                Circle()
                    .stroke()
                    .foregroundColor(Color(.errorRed))
                    .frame(width: 82, height: 82)
                
                ZStack {
                    Circle()
                        .foregroundColor(Color(.errorRed))
                    Image(.warningIcon)
                        .background(Color.clear)
                }
                .frame(width: 62, height: 62)
            }.accessibility(hidden: true)
            
            Text(message)
                .font(.body)
                .foregroundColor(Color(.primaryText))
                .fixedSize(horizontal: false, vertical: true)
                .multilineTextAlignment(.center)
            
            Button.underlined(
                text: buttonTitle,
                action: action
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
    static func makePausedIndicator(action: @escaping () -> Void, message: String, buttonTitle: String) -> AnyView {
        AnyView(PausedIndicator(action: action, message: message, buttonTitle: buttonTitle))
    }
}
