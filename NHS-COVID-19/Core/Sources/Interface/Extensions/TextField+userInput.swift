//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import UIKit

extension TextField {
    @discardableResult
    func styleForPostcodeEntry() -> Self {
        autocapitalizationType = .allCharacters
        textContentType = .postalCode
        return self
    }
}
