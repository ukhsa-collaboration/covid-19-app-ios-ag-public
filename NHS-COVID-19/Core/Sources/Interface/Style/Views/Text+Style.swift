//
// Copyright © 2021 NHSX. All rights reserved.
//

import SwiftUI

public extension Text {
    func styleAsBody() -> Text {
        self
            .font(.body)
            .foregroundColor(Color(.primaryText))
    }
    func styleAsHeading() -> Text {
        self
            .font(.headline)
            .foregroundColor(Color(.primaryText))
    }
    func styleAsSecondaryHeading() -> Text {
        self
            .font(.headline)
            .foregroundColor(Color(.secondaryText))
    }
}
