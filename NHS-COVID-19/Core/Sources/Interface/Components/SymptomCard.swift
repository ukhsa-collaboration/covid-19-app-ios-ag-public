//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Localization
import SwiftUI

public struct SymptomCard: View {
    @ObservedObject private var viewModel: SymptomInfo
    
    public init(viewModel: SymptomInfo) {
        self.viewModel = viewModel
    }
    
    public var body: some View {
        Button(action: {
            withAnimation {
                self.viewModel.isConfirmed.toggle()
            }
        }) {
            VStack(alignment: .leading) {
                HStack(alignment: .firstTextBaseline, spacing: .buttonCornerRadius) {
                    ZStack {
                        Image(systemName: "checkmark.square.fill")
                            .foregroundColor(Color(.nhsButtonGreen))
                            .opacity(viewModel.isConfirmed ? 1 : 0)
                        Image(systemName: "square")
                            .foregroundColor(Color(.secondaryText))
                            .opacity(viewModel.isConfirmed ? 0 : 1)
                    }
                    Text(verbatim: viewModel.heading)
                        .font(.headline)
                        .foregroundColor(Color(.primaryText))
                        .fixedSize(horizontal: false, vertical: true)
                }
                Color(.background).frame(height: 1)
                Text(verbatim: viewModel.content)
                    .font(.body)
                    .foregroundColor(Color(.primaryText))
                    .fixedSize(horizontal: false, vertical: true)
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
                    .symptom_card_checkbox_accessibility_label(
                        value: viewModel.isConfirmed ? localize(.symptom_card_checked, applyCurrentLanguageDirection: false) : localize(.symptom_card_unchecked, applyCurrentLanguageDirection: false),
                        heading: viewModel.heading,
                        content: viewModel.content
                    )
                )
            )
        )
        .accessibility(addTraits: .isButton)
        .environment(\.locale, Locale(identifier: currentLocaleIdentifier()))
    }
}
