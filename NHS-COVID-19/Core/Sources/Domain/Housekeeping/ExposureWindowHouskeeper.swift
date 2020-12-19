//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation
import Logging

class ExposureWindowHousekeeper {
    private static let logger = Logger(label: "ExposureWindowHousekeeper")
    
    private let getIsolationLogicalState: () -> IsolationLogicalState
    private let isWaitingForExposureApproval: () -> Bool
    private let clearExposureWindowData: () -> Void
    
    init(getIsolationLogicalState: @escaping () -> IsolationLogicalState,
         isWaitingForExposureApproval: @escaping () -> Bool,
         clearExposureWindowData: @escaping () -> Void) {
        self.getIsolationLogicalState = getIsolationLogicalState
        self.isWaitingForExposureApproval = isWaitingForExposureApproval
        self.clearExposureWindowData = clearExposureWindowData
    }
    
    func executeHousekeeping() -> AnyPublisher<Void, Never> {
        Future<Void, Never> { [weak self] promise in
            guard let self = self else {
                promise(.success(()))
                return
            }
            Self.logger.debug("execute housekeeping")
            let isolationLogicalState = self.getIsolationLogicalState()
            if !isolationLogicalState.isIsolating && !self.isWaitingForExposureApproval() {
                Self.logger.debug("deleting all exposure windows")
                self.clearExposureWindowData()
            }
            promise(.success(()))
        }.eraseToAnyPublisher()
    }
}
