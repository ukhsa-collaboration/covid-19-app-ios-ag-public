//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Localization
import SwiftUI

public struct NavigationButton: View {
    public enum ContentColorScheme {
        case matchEnvironment
        case override(SwiftUI.ColorScheme)
    }
    
    public class ColorScheme {
        var iconColor: Color
        var foregroundColor: Color
        var singleColor: Bool
        var fontColor: Color
        var imageBackgroundColor: Color
        var backgroundColor: Color {
            singleColor == true ? imageBackgroundColor : Color(.surface)
        }
        
        var contentColorScheme: ContentColorScheme
        
        init(
            iconColor: Color,
            foregroundColor: Color,
            backgroundColor: Color,
            singleColor: Bool,
            fontColor: Color,
            contentColorScheme: ContentColorScheme
        ) {
            self.iconColor = iconColor
            self.foregroundColor = foregroundColor
            imageBackgroundColor = backgroundColor
            self.singleColor = singleColor
            self.fontColor = fontColor
            self.contentColorScheme = contentColorScheme
        }
        
        static func standard(foregroundColor: Color, imageBackgroundColor: Color) -> ColorScheme {
            return .init(
                iconColor: Color(.secondaryText),
                foregroundColor: foregroundColor,
                backgroundColor: imageBackgroundColor,
                singleColor: false,
                fontColor: Color(.primaryText),
                contentColorScheme: .matchEnvironment
            )
        }
    }
    
    var action: () -> Void
    var imageName: ImageName
    var iconName: ImageName
    var text: String
    var font: Font
    var fontWeight: Font.Weight?
    var colorScheme: ColorScheme
    
    @SwiftUI.Environment(\.colorScheme) var environmentColorScheme
    
    public init(
        imageName: ImageName,
        iconName: ImageName = .menuChevron,
        foregroundColor: Color,
        backgroundColor: Color,
        text: String,
        font: Font = .body,
        fontWeight: Font.Weight? = nil,
        action: @escaping () -> Void
    ) {
        self.init(
            imageName: imageName,
            iconName: iconName,
            text: text,
            font: font,
            fontWeight: fontWeight,
            colorScheme: ColorScheme.standard(foregroundColor: foregroundColor, imageBackgroundColor: backgroundColor),
            action: action
        )
    }
    
    public init(
        imageName: ImageName,
        iconName: ImageName = .menuChevron,
        text: String,
        font: Font = .body,
        fontWeight: Font.Weight? = nil,
        colorScheme: ColorScheme,
        action: @escaping () -> Void
    ) {
        self.action = action
        self.imageName = imageName
        self.text = text
        self.iconName = iconName
        self.font = font
        self.fontWeight = fontWeight
        self.colorScheme = colorScheme
    }
    
    private var contentColorScheme: SwiftUI.ColorScheme {
        switch colorScheme.contentColorScheme {
        case .matchEnvironment:
            return environmentColorScheme
        case .override(let colorScheme):
            return colorScheme
        }
    }
    
    public var body: some View {
        Button(action: action) {
            ZStack(alignment: .leading) {
                colorScheme.imageBackgroundColor
                    .frame(width: .menuButtonColorWidth)
                HStack(spacing: .zero) {
                    ZStack {
                        Image(imageName)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(colorScheme.foregroundColor)
                            .frame(width: 30, height: 30)
                    }
                    .frame(width: .menuButtonColorWidth)
                    .colorScheme(contentColorScheme)
                    HStack(spacing: .standardSpacing) {
                        Text(text)
                            .font(font)
                            .fontWeight(fontWeight)
                            .foregroundColor(colorScheme.fontColor)
                            .fixedSize(horizontal: false, vertical: true)
                        Spacer()
                        Image(iconName)
                            .resizable()
                            .scaledToFit()
                            .foregroundColor(colorScheme.iconColor)
                            .frame(width: 30)
                    }
                    .colorScheme(contentColorScheme)
                    .padding(.standardSpacing)
                    .background(colorScheme.backgroundColor)
                }
            }
        }
        .background(colorScheme.backgroundColor)
        .clipShape(RoundedRectangle(cornerRadius: .menuButtonCornerRadius))
        .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.04), radius: .stripeWidth, x: 0, y: 0)
        
    }
}
