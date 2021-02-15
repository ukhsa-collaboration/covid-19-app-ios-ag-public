//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import Combine

/// Metrics are by default disabled until the user completes on-boarding which prevents suprious packets being uploaded if the user takes
/// some time to complete the process.
///
/// We use the application's RawState property to determine the current on-boarding state
///

extension RawState {
    var isOnboarded: Bool {
        return exposureState.authorizationState != .unknown && userNotificationsStatus != .unknown && postcodeState != .empty
    }
}

class MetricsState {
        
    enum State {
        case enabled, disabled
    }
    
    private var rawState: DomainProperty<RawState>?

    var state: State {
        guard let rawState = rawState else {
            return .disabled
        }
        return rawState.currentValue.isOnboarded ? .enabled : .disabled
    }
    
    func set(rawState: DomainProperty<RawState>) {
        self.rawState = rawState
    }
}
