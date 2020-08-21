//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Localization
import SwiftUI

public struct NavigationButton: View {
    var action: () -> Void
    var imageName: ImageName
    var foregroundColor: Color
    var backgroundColor: Color
    var text: String
    var font: Font
    var fontWeight: Font.Weight?
    
    public init(imageName: ImageName, foregroundColor: Color, backgroundColor: Color, text: String, font: Font = .body, fontWeight: Font.Weight? = nil, action: @escaping () -> Void) {
        self.action = action
        self.imageName = imageName
        self.text = text
        self.foregroundColor = foregroundColor
        self.backgroundColor = backgroundColor
        self.font = font
        self.fontWeight = fontWeight
    }
    
    public var body: some View {
        Button(action: action) {
            HStack(spacing: .zero) {
                ZStack {
                    backgroundColor
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(foregroundColor)
                        .frame(width: 30, height: 30)
                }
                .frame(width: 60)
                HStack(spacing: .standardSpacing) {
                    Text(text)
                        .font(font)
                        .fontWeight(fontWeight)
                        .foregroundColor(Color(.primaryText))
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                    Image(.menuChevron)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color(.secondaryText))
                        .frame(width: 30)
                }
                .padding(.standardSpacing)
            }
        }
        .background(Color(.surface))
        .clipShape(RoundedRectangle(cornerRadius: .menuButtonCornerRadius))
        .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.04), radius: .stripeWidth, x: 0, y: 0)
        
    }
}
