//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Localization
import SwiftUI

public struct NavigationButton: View {
    var action: () -> Void
    var imageName: ImageName
    var text: String
    
    public init(imageName: ImageName, text: String, action: @escaping () -> Void) {
        self.action = action
        self.imageName = imageName
        self.text = text
    }
    
    public var body: some View {
        Button(action: action) {
            ZStack {
                Color(.surface)
                    .clipShape(RoundedRectangle(cornerRadius: .menuButtonCornerRadius))
                    .shadow(color: Color(red: 0, green: 0, blue: 0, opacity: 0.04), radius: .stripeWidth, x: 0, y: 0)
                HStack(spacing: .standardSpacing) {
                    Image(imageName)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color(.nhsBlue))
                        .frame(width: 30)
                    Text(text)
                        .font(.body)
                        .foregroundColor(Color(.primaryText))
                        .fixedSize(horizontal: false, vertical: true)
                    Spacer()
                    Image(.menuChevron)
                        .resizable()
                        .scaledToFit()
                        .foregroundColor(Color(.nhsBlue))
                        .frame(width: 30)
                }
                .padding(.standardSpacing)
            }
        }
    }
}
