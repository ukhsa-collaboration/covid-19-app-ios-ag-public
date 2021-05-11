//
// Copyright © 2021 DHSC. All rights reserved.
//

import SwiftUI

public struct BulletItems: View {
    let rows: [String]
    static let bulletStyle = SymbolProperties(type: .fullCircle, size: .halfSpacing, color: .nhsBlue)
    public var body: some View {
        VStack(alignment: .leading, spacing: .halfSpacing) {
            ForEach(rows, id: \.self) { row in
                HStack(alignment: .firstTextBaseline) {
                    // ensure the bullet point aligns with the first line of the text by getting it
                    // to center align with an invisible character which scales the same way when
                    // the dynamic text settings change
                    HStack(alignment: .center) {
                        Circle()
                            .fill(Color(Self.bulletStyle.color))
                            .frame(width: Self.bulletStyle.size, height: Self.bulletStyle.size)
                        Text("\u{00A0}")
                            .styleAsBody()
                            .frame(width: 0)
                    }
                    .frame(width: Self.bulletStyle.size)
                    .accessibility(hidden: true)
                    
                    Text(row)
                        .styleAsBody()
                }
            }
        }
    }
}
