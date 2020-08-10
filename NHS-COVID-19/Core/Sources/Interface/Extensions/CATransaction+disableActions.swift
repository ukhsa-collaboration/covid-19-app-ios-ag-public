//
// Copyright © 2020 NHSX. All rights reserved.
//

import QuartzCore

extension CATransaction {
    static func disableActions(block: () -> Void) {
        begin()
        disableActions()
        block()
        commit()
    }
}
