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
        VStack(alignment: .leading, spacing: .halfSpacing) {
            ForEach(rows, id: \.self) { row in
                HStack(alignment: .firstTextBaseline) {
                    Circle()
                        .fill(Color(Self.bulletStyle.color))
                        .frame(width: Self.bulletStyle.size, height: Self.bulletStyle.size)
                        .textBaselineAligned(font: .body)
                    
                    Text(row)
                        .styleAsBody()
                }
            }
        }
    }
}
