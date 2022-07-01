//
// Copyright © 2021 DHSC. All rights reserved.
//

import SwiftUI

public struct BulletItems: View {
    static let bulletStyle = SymbolProperties(type: .fullCircle, size: .halfSpacing, color: .nhsBlue)
    private let rows: [String]

    public init(rows: [String]) {
        self.rows = rows
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: .standardSpacing) {
            ForEach(rows, id: \.self) { row in
                HStack(alignment: .firstTextBaseline) {
                    Circle()
                        .fill(Color(Self.bulletStyle.color))
                        .frame(width: Self.bulletStyle.size, height: Self.bulletStyle.size)
                        .textBaselineAligned(font: .body)

                    Text(row)
                        .styleAsBody()

                    Spacer()
                }
            }
        }
    }
}

public struct NumberedBulletItems: View {
    static let bulletSize = CGFloat.halfSpacing
    static let bulletColor = ColorName.nhsBlue
    private let rows: [String]
    private let accessibilityTextForRow: (Int, String) -> String

    public init(rows: [String],
                accessibilityTextForRow: @escaping (Int, String) -> String) {
        self.rows = rows
        self.accessibilityTextForRow = accessibilityTextForRow
    }

    public var body: some View {
        VStack(alignment: .leading, spacing: .standardSpacing) {
            ForEach(rows.indices, id: \.self) { index in
                let stepNumber = index + 1

                HStack(
                    alignment: .top,
                    spacing: .standardSpacing
                ) {
                    Text("\(stepNumber)")
                        .font(.headline)
                        .fontWeight(.heavy)
                        .foregroundColor(Color(.background))
                        .padding(CGFloat.symbolIconWidth / 2)
                        .background(Color(.nhsBlue))
                        .clipShape(SwiftUI.Circle())

                    Text(rows[index]).styleAsBody()

                    Spacer()
                }
                .accessibilityElement()
                .accessibility(label: Text(accessibilityTextForRow(stepNumber, rows[index])))
            }
        }
    }
}
