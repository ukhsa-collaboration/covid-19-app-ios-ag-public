//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation

public enum IsolationPaymentState {
    case disabled
    case enabled(apply: () -> AnyPublisher<URL, NetworkRequestError>)
}

enum IsolationPaymentRawState: Equatable {
    case disabled
    case ipcToken(String)
}
