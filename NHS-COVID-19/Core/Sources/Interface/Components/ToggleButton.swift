//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Localization
import SwiftUI

public struct ToggleButton: View {
    @Binding private var isToggledOn: Bool
    var imageName: ImageName?
    var text: String
    
    public init(isToggledOn: Binding<Bool>, imageName: ImageName? = nil, text: String) {
        self.imageName = imageName
        self.text = text
        _isToggledOn = isToggledOn
    }
    
    public var body: some View {
        HStack(spacing: .zero) {
            if let imageName = imageName {
                ZStack {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color(.primaryText))
                        .frame(width: 30, height: 30)
                        .accessibility(hidden: true)
                }.frame(width: 60)
            }
            Toggle(text, isOn: $isToggledOn)
                .accessibility(label: Text(text)) // fixes accessibility label when the switch is turned off and turned back on again
                .font(.body)
                .foregroundColor(Color(.primaryText))
                .fixedSize(horizontal: false, vertical: true)
                .padding(.standardSpacing)
        }
        .background(Color(.surface))
        .clipShape(RoundedRectangle(cornerRadius: .menuButtonCornerRadius))
        .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.04), radius: .stripeWidth, x: 0, y: 0)
        .environment(\.locale, Locale(identifier: currentLocaleIdentifier()))
    }
}
