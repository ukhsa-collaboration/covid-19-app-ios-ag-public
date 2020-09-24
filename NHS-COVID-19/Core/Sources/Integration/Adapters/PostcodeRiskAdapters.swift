//
// Copyright © 2020 NHSX. All rights reserved.
//

import Domain
import Interface

extension RiskLevelBanner.ViewModel.RiskLevel {
    init?(postcodeRisk: PostcodeRisk?) {
        switch postcodeRisk {
        case nil: return nil
        case .low: self = .low
        case .medium: self = .medium
        case .high: self = .high
        }
    }
}
