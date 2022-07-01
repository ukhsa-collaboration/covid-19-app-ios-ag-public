//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import SwiftUI

public struct ErrorBox: View {

    private var heading: String
    private var description: String

    public init(_ heading: String, description: String) {
        self.heading = heading
        self.description = description
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: .buttonCornerRadius) {
            Text(verbatim: heading)
                .font(.title)
                .foregroundColor(Color(.primaryText))
                .fixedSize(horizontal: false, vertical: true)
            Text(verbatim: description)
                .font(.headline)
                .foregroundColor(Color(.errorRed))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding()
        .border(Color(.errorRed), width: 4)
        .accessibilityElement()
        .accessibility(label: Text(verbatim: localize(.symptom_card_accessibility_label(heading: heading, content: description))))
        .accessibility(addTraits: .isStaticText)
        .environment(\.locale, Locale(identifier: currentLocaleIdentifier()))
    }
}
