//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct IsolationPaymentTokenUpdate {
    var ipcToken: String
    var riskyEncounterDay: GregorianDay
    var isolationPeriodEndsAtStartOfDay: GregorianDay
}
