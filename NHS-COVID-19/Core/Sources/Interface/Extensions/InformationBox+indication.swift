//
// Copyright © 2020 NHSX. All rights reserved.
//

import UIKit

extension InformationBox {
    public static func indication(text: String, style: Style) -> InformationBox {
        InformationBox(
            views: [UILabel().styleAsSecondaryTitle().set(text: text)],
            style: style,
            backgroundColor: UIColor(.surface)
        )
    }
    
    public static var indication: (
        goodNews: (String) -> InformationBox,
        badNews: (String) -> InformationBox,
        warning: (String) -> InformationBox
    ) {
        (
            { .indication(text: $0, style: .goodNews) },
            { .indication(text: $0, style: .badNews) },
            { .indication(text: $0, style: .warning) }
        )
    }
}
