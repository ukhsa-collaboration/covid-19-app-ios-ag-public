//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

public extension String {
    var alphamuneric: String {
        let alphamunericsString = components(separatedBy: CharacterSet.alphanumerics.inverted)
            .joined()
        return alphamunericsString
    }
}
