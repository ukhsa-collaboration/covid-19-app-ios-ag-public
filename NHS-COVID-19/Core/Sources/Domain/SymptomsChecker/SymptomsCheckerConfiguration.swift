//
// Copyright © 2022 DHSC. All rights reserved.
//

import Common
import Foundation

struct SymptomsCheckerConfiguration: Equatable {
    var analyticsPeriod: DayDuration

    static let `default` = SymptomsCheckerConfiguration(
        analyticsPeriod: 14
    )
}
