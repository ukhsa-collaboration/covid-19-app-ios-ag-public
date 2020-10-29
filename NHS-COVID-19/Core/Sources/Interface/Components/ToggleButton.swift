//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Localization
import SwiftUI

public struct ToggleButton: View {
    @Binding private var isToggledOn: Bool
    var imageName: ImageName
    var text: String
    
    public init(isToggledOn: Binding<Bool>, imageName: ImageName, text: String) {
        self.imageName = imageName
        self.text = text
        _isToggledOn = isToggledOn
    }
    
    public var body: some View {
        HStack(spacing: .zero) {
            ZStack {
                Image(imageName)
                    .resizable()
                    .scaledToFit()
                    .foregroundColor(Color(.primaryText))
                    .frame(width: 30, height: 30)
                    .accessibility(hidden: true)
            }.frame(width: 60)
            Toggle(text, isOn: $isToggledOn)
                .font(.body)
                .foregroundColor(Color(.primaryText))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.standardSpacing)
                .adjustActivationPointForSimulator()
        }
        .background(Color(.surface))
        .clipShape(RoundedRectangle(cornerRadius: .menuButtonCornerRadius))
        .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.04), radius: .stripeWidth, x: 0, y: 0)
    }
}

private extension View {
    
    func adjustActivationPointForSimulator() -> some View {
        #if targetEnvironment(simulator)
        #warning("Review if an Xcode update fixes this.")
        // There seem to be an issue causing this element to have incorrect activation point, but *only* with Xcode 12
        // and on the simulator; causing UI tests to fail.
        if UIApplication.shared.userInterfaceLayoutDirection == .leftToRight {
            return accessibility(activationPoint: UnitPoint(x: 0.95, y: 0.5))
        } else {
            return accessibility(activationPoint: UnitPoint(x: 0.05, y: 0.5))
        }
        #else
        return self
        #endif
    }
    
}
