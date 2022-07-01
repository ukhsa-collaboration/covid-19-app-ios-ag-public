//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import Localization
import SwiftUI

extension Text {

    init(_ key: StringLocalizableKey) {
        self.init(verbatim: localize(key))
    }

    init(_ key: ParameterisedStringLocalizable) {
        self.init(verbatim: localize(key))
    }

}
