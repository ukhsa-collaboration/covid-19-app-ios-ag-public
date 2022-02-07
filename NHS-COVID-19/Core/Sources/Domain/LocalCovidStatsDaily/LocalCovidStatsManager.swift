//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Foundation

public protocol LocalCovidStatsManaging {
    func fetchLocalCovidStats() -> AnyPublisher<LocalCovidStatsDaily, NetworkRequestError>
}

class LocalCovidStatsManager: LocalCovidStatsManaging {
    private let httpClient: HTTPClient
    init(
        httpClient: HTTPClient
    ) {
        self.httpClient = httpClient
    }
    
    func fetchLocalCovidStats() -> AnyPublisher<LocalCovidStatsDaily, NetworkRequestError> {
        httpClient.fetch(LocalCovidStatsDailyEndpoint())
    }
}
