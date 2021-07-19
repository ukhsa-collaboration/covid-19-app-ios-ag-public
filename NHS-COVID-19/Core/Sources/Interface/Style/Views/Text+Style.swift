//
// Copyright © 2021 DHSC. All rights reserved.
//

import SwiftUI

public extension Text {
    func styleAsBody() -> Text {
        font(.body)
            .foregroundColor(Color(.primaryText))
    }
    
    func styleAsSecondaryBody() -> Text {
        font(.body)
            .foregroundColor(Color(.secondaryText))
    }
    
    func styleAsHeading() -> some View {
        font(.headline)
            .foregroundColor(Color(.primaryText))
            .accessibility(addTraits: .isHeader)
    }
    
    func styleAsSecondaryHeading() -> some View {
        font(.headline)
            .foregroundColor(Color(.secondaryText))
            .accessibility(addTraits: .isHeader)
    }
}
