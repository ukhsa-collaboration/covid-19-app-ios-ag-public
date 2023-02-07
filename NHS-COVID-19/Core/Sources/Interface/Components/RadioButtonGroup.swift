//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import Localization
import SwiftUI

public struct RadioButtonGroup: View {

    public class State: ObservableObject {
        @Published public var selectedID: UUID?

        public init(selectedID: UUID? = nil) {
            self.selectedID = selectedID
        }
    }

    public struct ButtonViewModel {
        public let title: String
        public let accessibilityText: String?
        public let action: () -> Void
        public let id = UUID()

        public init(title: String, accessibilityText: String? = nil, action: @escaping () -> Void) {
            self.title = title
            self.action = action
            self.accessibilityText = accessibilityText
        }
    }

    private var buttonViewModels: [ButtonViewModel]
    @ObservedObject public private(set) var state: State
    private var alignment: RadioButtonAlignment

    public enum RadioButtonAlignment {
        case horizontal
        case vertical
    }

    public init(buttonViewModels: [ButtonViewModel], state: State = State(), alignment: RadioButtonAlignment = .horizontal) {
        self.buttonViewModels = buttonViewModels
        self.state = state
        self.alignment = alignment
    }

    public var body: some View {
        ZStack {
            switch alignment {
            case .horizontal:
                HStack(alignment: .firstTextBaseline, spacing: .standardSpacing) {
                    content
                    Spacer()
                }
            case .vertical:
                VStack(spacing: .standardSpacing) { content }
            }
        }
        .environment(\.locale, Locale(identifier: currentLocaleIdentifier()))
        .environment(\.layoutDirection, currentLanguageDirection() == .rightToLeft ? .rightToLeft : .leftToRight)
    }

    private var content: some View {
        ForEach(0..<buttonViewModels.count, id: \.self) { index in
            RadioButton(
                title: buttonViewModels[index].title,
                accessibilityText: buttonViewModels[index].accessibilityText,
                isSelected: state.selectedID == buttonViewModels[index].id,
                alignment: alignment
            ) {
                state.selectedID = buttonViewModels[index].id
                buttonViewModels[index].action()
            }
        }
    }
}

private struct RadioButton: View {
    let title: String
    let accessibilityText: String?
    let isSelected: Bool
    let alignment: RadioButtonGroup.RadioButtonAlignment
    let action: () -> Void

    public var body: some View {
        Button(action: {
            withAnimation { action() }
        }) {
            HStack(alignment: .firstTextBaseline, spacing: .halfSpacing) {
                ZStack {
                    Image(systemName: "checkmark.circle.fill")
                        .foregroundColor(Color(.nhsButtonGreen))
                        .opacity(isSelected ? 1 : 0)
                    Image(systemName: "circle")
                        .foregroundColor(Color(.secondaryText))
                        .opacity(isSelected ? 0 : 1)
                }
                Text(verbatim: title)
                    .font(.headline)
                    .foregroundColor(Color(.primaryText))
                    .fixedSize(horizontal: false, vertical: true)
                if alignment == .vertical {
                    Spacer()
                }
            }
            .padding()
            .background(Color(.surface))
            .clipShape(RoundedRectangle(cornerRadius: .buttonCornerRadius))
            .overlay(
                RoundedRectangle(cornerRadius: .buttonCornerRadius)
                    .stroke(
                        isSelected ? Color(.nhsButtonGreen) : Color(.secondaryText),
                        lineWidth: .halfHairSpacing
                    )
            )
        }
        .buttonStyle(PlainButtonStyle())
        .accessibilityElement()
        .accessibility(
            label: Text(
                verbatim: localize(
                    .radio_button_accessibility_label(
                        value: isSelected ? localize(.radio_button_checked) : localize(.radio_button_unchecked),
                        content: accessibilityText ?? title
                    )
                )
            )
        )
        .accessibility(addTraits: .isButton)
    }
}
