//
// Copyright © 2021 DHSC. All rights reserved.
//

import SwiftUI

public extension Button where Label == Text {
    
    static func underlined(text: String, action: @escaping () -> Void) -> Button {
        Button(
            action: action,
            label: {
                Text(text)
                    .underline()
                    .baselineOffset(5)
            }
        )
    }
}
