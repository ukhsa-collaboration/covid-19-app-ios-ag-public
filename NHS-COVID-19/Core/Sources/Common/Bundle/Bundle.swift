//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

extension Bundle {
    public var supportedLocalizations: [String] {
        localizations.filter { $0 != "Base" }
    }
}
