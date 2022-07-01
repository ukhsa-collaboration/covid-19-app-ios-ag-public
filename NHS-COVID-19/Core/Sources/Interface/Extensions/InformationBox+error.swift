//
// Copyright © 2020 NHSX. All rights reserved.
//

import UIKit

extension InformationBox {
    public static func error(_ views: UIView..., errored: Bool = false) -> InformationBox {
        .error(views, errored: errored)
    }

    public static func error(_ views: [UIView], errored: Bool = false) -> InformationBox {
        InformationBox(
            views: views,
            style: errored ? .badNews : .noNews,
            backgroundColor: .clear
        )
    }

    public func error() {
        style = .badNews
    }
}
