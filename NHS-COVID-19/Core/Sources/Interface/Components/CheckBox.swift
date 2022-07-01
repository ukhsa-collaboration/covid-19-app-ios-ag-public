//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import SwiftUI

public class CheckBoxInfo: ObservableObject, Identifiable {
    @Published public var isConfirmed: Bool
    public var heading: String

    public init(isConfirmed: Bool, heading: String) {
        self.heading = heading
        self.isConfirmed = isConfirmed
    }
}

public struct CheckBox: View {
    @ObservedObject private var viewModel: CheckBoxInfo

    public init(viewModel: CheckBoxInfo) {
        self.viewModel = viewModel
    }

    public var body: some View {
        Button(action: {
            withAnimation {
                self.viewModel.isConfirmed.toggle()
            }
        }) {

            HStack {
                ZStack {
                    Image(systemName: "checkmark.square.fill")
                        .foregroundColor(Color(.nhsButtonGreen))
                        .opacity(viewModel.isConfirmed ? 1 : 0)
                    Image(systemName: "square")
                        .foregroundColor(Color(.secondaryText))
                        .opacity(viewModel.isConfirmed ? 0 : 1)
                }
                Text(verbatim: viewModel.heading)
                    .font(.body)
                    .foregroundColor(Color(.primaryText))
                    .fixedSize(horizontal: false, vertical: true)
                Spacer()
            }
            .padding()
            .background(Color(.surface))
            .clipShape(RoundedRectangle(cornerRadius: .buttonCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: .buttonCornerRadius)
                    .stroke(
                        viewModel.isConfirmed ? Color(.nhsButtonGreen) : Color(.surface),
                        lineWidth: 2
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityElement()
        .accessibility(
            label: Text(
                verbatim: localize(
                    .local_authority_card_checkbox_accessibility_label(
                        value: viewModel.isConfirmed ? localize(.symptom_card_checked) : localize(.symptom_card_unchecked),
                        content: viewModel.heading
                    )
                )
            )
        )
        .accessibility(addTraits: .isButton)
        .environment(\.locale, Locale(identifier: currentLocaleIdentifier()))
    }
}
