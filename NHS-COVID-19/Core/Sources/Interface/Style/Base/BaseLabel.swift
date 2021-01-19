//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import Localization
import UIKit

class BaseLabel: UILabel {
    init() {
        super.init(frame: .zero)
        switch currentLanguageDirection() {
        case .rightToLeft: textAlignment = .right
        case .leftToRight: textAlignment = .left
        case .unknown: break
        }
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
