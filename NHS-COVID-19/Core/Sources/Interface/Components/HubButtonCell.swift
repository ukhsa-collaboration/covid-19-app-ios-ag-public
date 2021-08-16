//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import SwiftUI

public struct HubButtonCell: View {
    public struct ViewModel {
        let title: String
        let description: String
        let accessoryImageName: ImageName
        let action: () -> Void
        
        public init(
            title: String,
            description: String,
            iconName: ImageName = .menuChevron,
            action: @escaping () -> Void
        ) {
            self.title = title
            self.description = description
            accessoryImageName = iconName
            self.action = action
        }
    }
    
    private let viewModel: ViewModel
    
    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        let button = Button(action: viewModel.action) {
            HStack {
                VStack(alignment: .leading, spacing: .halfSpacing) {
                    Text(viewModel.title)
                        .styleAsHeading()
                        .accessibility(removeTraits: .isHeader)
                    Text(viewModel.description)
                        .styleAsSecondaryBody()
                }
                .fixedSize(horizontal: false, vertical: true)
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Image(viewModel.accessoryImageName)
                    .frame(width: .symbolIconWidth, height: .symbolIconWidth)
                    .foregroundColor(Color(.primaryText))
            }
            .padding(.standardSpacing)
            .contentShape(Rectangle()) // fixes tap outside of padding
        }
        .buttonStyle(PlainButtonStyle())
        .background(Color(.surface))
        .environment(\.locale, Locale(identifier: currentLocaleIdentifier()))
        
        if viewModel.accessoryImageName == .externalLink {
            let linkText = viewModel.title + ", " + viewModel.description
            return AnyView(button.linkify(linkText))
        }
        return AnyView(button)
    }
    
}
