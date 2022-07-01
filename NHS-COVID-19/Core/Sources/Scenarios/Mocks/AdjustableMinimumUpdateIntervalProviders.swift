//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Domain
import Foundation

final class RiskyPostcodeAdjustableMinimumUpdateIntervalProvider: MinimumUpdateIntervalProviding {

    private(set) var interval: TimeInterval
    private var cancellable: AnyCancellable?

    init(dataProvider: MockDataProvider = .shared) {
        interval = TimeInterval(dataProvider.riskyLocalAuthorityMinimumBackgroundTaskUpdateInterval)

        cancellable = dataProvider.riskyLocalAuthorityMinimumBackgroundTaskUpdateIntervalDidChange
            .sink { [weak self] value in
                self?.interval = TimeInterval(value)
            }
    }

}
