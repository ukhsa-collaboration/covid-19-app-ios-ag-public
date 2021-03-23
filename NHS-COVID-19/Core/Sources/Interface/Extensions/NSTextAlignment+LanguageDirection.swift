//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import UIKit

extension NSTextAlignment {
    static var leading: Self {
        switch currentLanguageDirection() {
        case .rightToLeft: return .right
        case .leftToRight: return .left
        case .unknown:
            assertionFailure("Should not be possible")
            return .left
        }
    }
    
    static var trailing: Self {
        switch currentLanguageDirection() {
        case .rightToLeft: return .left
        case .leftToRight: return .right
        case .unknown:
            assertionFailure("Should not be possible")
            return .right
        }
    }
}
