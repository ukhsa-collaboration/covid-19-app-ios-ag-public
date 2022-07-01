//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation

protocol NonRiskyWindowSelecting {
    var allow: Bool { get }
}

struct NonRiskyWindowSelector: NonRiskyWindowSelecting {

    var allow: Bool {
        // 2.5% this will return true
        Int.random(in: 0 ... 999) < 25
    }
}
