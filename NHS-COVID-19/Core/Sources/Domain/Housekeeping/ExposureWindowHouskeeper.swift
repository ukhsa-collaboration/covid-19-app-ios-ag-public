//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation
import Logging

class ExposureWindowHousekeeper {
    private static let logger = Logger(label: "ExposureWindowHousekeeper")
    
    private let deleteExpiredExposureWindows: () -> Void
    
    init(deleteExpiredExposureWindows: @escaping () -> Void) {
        self.deleteExpiredExposureWindows = deleteExpiredExposureWindows
    }
    
    func executeHousekeeping() -> AnyPublisher<Void, Never> {
        Future<Void, Never> { [weak self] promise in
            guard let self = self else {
                promise(.success(()))
                return
            }
            Self.logger.debug("execute housekeeping; deleting expired exposure windows")
            self.deleteExpiredExposureWindows()
            promise(.success(()))
        }.eraseToAnyPublisher()
    }
}
