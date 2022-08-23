//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Localization
import SwiftUI

public struct HubButtonCell: View {
    public struct ViewModel {
        let title: String
        let description: String
        let accessoryImageName: ImageName
        let action: () -> Void
        let accessibilityLabel: String

        public init(
            title: String,
            description: String,
            iconName: ImageName = .menuChevron,
            action: @escaping () -> Void,
            accessibilityLabel: String = ""
        ) {
            self.title = title
            self.description = description
            accessoryImageName = iconName
            self.action = action
            self.accessibilityLabel = accessibilityLabel

        }
    }

    private let viewModel: ViewModel
    @ObservedObject private var shouldShowNewLabelState: NewLabelState

    public init(viewModel: ViewModel, shouldShowNewLabelState: NewLabelState = NewLabelState()) {
        self.viewModel = viewModel
        self.shouldShowNewLabelState = shouldShowNewLabelState
    }
    var font: Font = .body
    public var body: some View {
        let button = Button(action: viewModel.action) {
            HStack {
                VStack(alignment: .leading, spacing: .halfSpacing) {
                    Spacer()
                    if $shouldShowNewLabelState.shouldNotShowNewLabel.wrappedValue == false && shouldShowNewLabelState.setByCoordinator {
                        Text(localize(.home_new_label))
                            .font(font)
                            .fontWeight(.bold)
                            .foregroundColor(Color.white)
                            .lineLimit(1)
                            .minimumScaleFactor(0.2)
                            .fixedSize(horizontal: false, vertical: true)
                            .multilineTextAlignment(.center)
                            .padding([.all], 4)
                            .background(Rectangle().fill(Color(red: 188 / 255, green: 90 / 255, blue: 0 / 255)))
                            .cornerRadius(5)

                    }
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
            let accessibilityLabelNewLabel = $shouldShowNewLabelState.shouldNotShowNewLabel.wrappedValue == false && shouldShowNewLabelState.setByCoordinator ?  viewModel.accessibilityLabel : ""
            let linkText = accessibilityLabelNewLabel + viewModel.title + ", " + viewModel.description
            return AnyView(button.linkify(linkText))
        }
        return AnyView(button)
    }

}
