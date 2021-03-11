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
            fetchRiskyVenues: fetchRiskyVenues,
            riskyVenueConfiguration: CachedResponse(
                httpClient: client,
                endpoint: RiskyVenuesConfigurationEndpoint(),
                storage: FileStorage(forNewCachesOf: .random()),
                name: "risky_venue_configuration",
                initialValue: RiskyVenueConfiguration(optionToBookATest: 11)
            )
        )
        
        addTeardownBlock {
            self.checkInsManager = nil
        }
    }
    
    func testMakeBackgroundJobs() throws {
        let backgroundJobs = checkInsManager.makeBackgroundJobs(
            metricsFrequency: 1.0,
            housekeepingFrequency: 1.0
        )
        
        XCTAssertEqual(backgroundJobs.count, 2)
        
        try backgroundJobs.forEach { job in
            try job.work().await().get()
        }
        
        let request = try XCTUnwrap(client.lastRequest)
        let expectedRequest = try RiskyVenuesConfigurationEndpoint().request(for: ())
        XCTAssertEqual(request, expectedRequest)
    }
}
