//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Localization
import SwiftUI

public struct LocalAuthorityCard: View {
    var viewModel: LocalAuthority
    @Binding var selectedLocalAuthority: LocalAuthority?
    var selectLocalAuthority: (LocalAuthority) -> Void
    
    // MARK: - Init
    
    func isConfirmed() -> Bool {
        selectedLocalAuthority == viewModel
    }
    
    public var body: some View {
        Button(action: {
            withAnimation {
                selectedLocalAuthority = viewModel
                selectLocalAuthority(viewModel)
            }
        }) {
            HStack(alignment: .firstTextBaseline, spacing: .buttonCornerRadius) {
                ZStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(.nhsButtonGreen))
                        .opacity(isConfirmed() ? 1 : 0)
                    Image(systemName: "circle")
                        .foregroundColor(Color(.secondaryText))
                        .opacity(isConfirmed() ? 0 : 1)
                }
                Text(verbatim: viewModel.name)
                    .font(.headline)
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
                        isConfirmed() ? Color(.nhsButtonGreen) : Color(.surface),
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
                        value: isConfirmed() ? localize(.symptom_card_checked) : localize(.symptom_card_unchecked),
                        content: viewModel.name
                    )
                )
            )
        )
        .accessibility(addTraits: .isButton)
        .environment(\.locale, Locale(identifier: currentLocaleIdentifier()))
    }
}
