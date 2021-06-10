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
    
    func styleAsHeading() -> Text {
        font(.headline)
            .foregroundColor(Color(.primaryText))
    }
    
    func styleAsSecondaryHeading() -> Text {
        font(.headline)
            .foregroundColor(Color(.secondaryText))
    }
}
