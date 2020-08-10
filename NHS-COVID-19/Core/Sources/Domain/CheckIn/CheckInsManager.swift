//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation

public struct CheckInsManager {
    
    private static let numberOfPersistingDays: Int = 21
    
    var checkInsStoreLoad: () -> CheckIns?
    var checkInsStoreDeleteExpired: (UTCHour) -> Void
    var updateRisk: ([String]) -> Void
    var fetchRiskyVenues: () -> AnyPublisher<[RiskyVenue], NetworkRequestError>
    
    func deleteExpiredCheckIns() -> AnyPublisher<Void, Never> {
        let now = LocalDay.today.advanced(by: -Self.numberOfPersistingDays)
        checkInsStoreDeleteExpired(UTCHour(roundedDownToQuarter: now.startOfDay))
        return Just(()).eraseToAnyPublisher()
    }
    
    func evaluateVenuesRisk() -> AnyPublisher<Void, Never> {
        guard let checkIns = checkInsStoreLoad() else {
            return Just(()).eraseToAnyPublisher()
        }
        return fetchRiskyVenues()
            .map {
                Self.matchRiskyVenues($0, with: checkIns)
            }
            .map(updateRisk)
            .replaceError(with: ())
            .eraseToAnyPublisher()
    }
    
    private static func matchRiskyVenues(_ riskyVenues: [RiskyVenue], with checkIns: CheckIns) -> [String] {
        riskyVenues.filter { riskyVenue in
            checkIns.contains { checkIn in
                checkIn.venueId.caseInsensitiveCompare(riskyVenue.id) == .orderedSame &&
                    riskyVenue.riskyInterval.intersects(checkIn.checkedInInterval)
            }
        }.map { $0.id }
    }
    
}

extension CheckInsManager {
    init(checkInsStore: CheckInsStore, httpClient: HTTPClient) {
        self.init(
            checkInsStoreLoad: checkInsStore.load,
            checkInsStoreDeleteExpired: checkInsStore.deleteExpired,
            updateRisk: checkInsStore.updateRisk,
            fetchRiskyVenues: { httpClient.fetch(RiskyVenuesEndpoint()) }
        )
    }
}
