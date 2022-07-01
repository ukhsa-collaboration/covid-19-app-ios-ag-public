//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Scenarios
import TestSupport
import XCTest
@testable import Domain

class CheckInsManagerTests: XCTestCase {
    var checkInsManager: CheckInsManager!

    var providedRiskyVenues = [RiskyVenue]()

    func fetchRiskyVenues() -> AnyPublisher<[RiskyVenue], NetworkRequestError> {
        Result.success(providedRiskyVenues).publisher.eraseToAnyPublisher()
    }

    var checkIns: [CheckIn] = []

    func save(_ checkIn: CheckIn) {
        checkIns.append(checkIn)
    }

    var deletedCheckinsBefore: UTCHour?

    var actualRiskyVenues: [RiskyVenue]?

    private var client: MockHTTPClient!

    override func setUp() {
        checkIns = []
        client = MockHTTPClient()
        checkInsManager = CheckInsManager(
            checkInsStoreLoad: { self.checkIns },
            checkInsStoreDeleteExpired: { self.deletedCheckinsBefore = $0 },
            updateRisk: {
                self.actualRiskyVenues = $0
            },
            fetchRiskyVenues: fetchRiskyVenues
        )

        addTeardownBlock {
            self.checkInsManager = nil
        }
    }
}
