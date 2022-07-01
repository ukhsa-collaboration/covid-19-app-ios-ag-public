//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Scenarios
import TestSupport
import XCTest
@testable import Domain

class CheckInContextTest: XCTestCase {
    private var checkInContext: CheckInContext!
    private var client: MockHTTPClient!
    private var checkInsStore: CheckInsStore!
    private var optionToBookATestDuration = 14

    override func setUp() {
        client = MockHTTPClient()

        checkInsStore = CheckInsStore(
            store: MockEncryptedStore(),
            venueDecoder: VenueDecoder.forTests,
            getCachedRiskyVenueConfiguration: {
                RiskyVenueConfiguration(
                    optionToBookATest: DayDuration(self.optionToBookATestDuration)
                )
            }
        )

        let checkInManager = CheckInsManager(
            checkInsStore: checkInsStore,
            httpClient: client
        )

        let qrCodeScanner = QRCodeScanner(
            cameraManager: MockCameraManager(),
            cameraStateController: CameraStateController(
                manager: MockCameraManager(),
                notificationCenter: NotificationCenter()
            )
        )

        let configuration = CachedResponse(
            httpClient: client,
            endpoint: RiskyVenuesConfigurationEndpoint(),
            storage: FileStorage(forCachesOf: .random()),
            name: "risky_venue_configuration",
            initialValue: RiskyVenueConfiguration(optionToBookATest: DayDuration(optionToBookATestDuration))
        )

        checkInContext = CheckInContext(
            checkInsStore: checkInsStore,
            checkInsManager: checkInManager,
            qrCodeScanner: qrCodeScanner,
            currentDateProvider: MockDateProvider { Date() },
            riskyVenueConfiguration: configuration
        )
    }

    func testMakeBackgroundJobs() throws {
        let backgroundJobs = checkInContext.makeBackgroundJobs()

        XCTAssertEqual(backgroundJobs.count, 2)

        try backgroundJobs.forEach { job in
            try job.work().await().get()
        }

        let request = try XCTUnwrap(client.lastRequest)
        let expectedRequest = try RiskyVenuesConfigurationEndpoint().request(for: ())
        XCTAssertEqual(request, expectedRequest)
    }

    func testRecentlyVisitedSevereRiskyVenue() throws {
        let venue1checkInDay = GregorianDay.today.advanced(by: -(optionToBookATestDuration - 1))
        let venue2checkInDay = GregorianDay.today.advanced(by: -(optionToBookATestDuration - 5))

        XCTAssertNil(checkInContext.recentlyVisitedSevereRiskyVenue.currentValue)

        var c1 = CheckIn(venue: Venue(id: "DCJK2345", organisation: "test"), checkedIn: UTCHour(day: venue1checkInDay, hour: 5, minutes: 0), checkedOut: UTCHour(day: venue1checkInDay, hour: 7, minutes: 0), isRisky: false)
        c1 = try c1.changeToRiskyWarnAndBookATest()
        checkInsStore.save(c1)

        var c2 = CheckIn(venue: Venue(id: "DCJK2346", organisation: "test"), checkedIn: UTCHour(day: venue2checkInDay, hour: 5, minutes: 0), checkedOut: UTCHour(day: venue2checkInDay, hour: 7, minutes: 0), isRisky: false)
        c2 = try c2.changeToRiskyWarnAndBookATest()
        checkInsStore.save(c2)

        _ = try XCTUnwrap(checkInsStore.load())

        checkInsStore.set(CircuitBreakerApproval.yes, for: "DCJK2345")
        checkInsStore.set(CircuitBreakerApproval.yes, for: "DCJK2346")

        XCTAssertEqual(checkInContext.recentlyVisitedSevereRiskyVenue.currentValue, venue2checkInDay)
    }

    func testRecentlyDidNotVisitSevereRiskyVenue() throws {
        let checkInDay = GregorianDay.today.advanced(by: -optionToBookATestDuration)

        XCTAssertNil(checkInContext.recentlyVisitedSevereRiskyVenue.currentValue)

        var c1 = CheckIn(venue: Venue(id: "DCJK2345", organisation: "test"), checkedIn: UTCHour(day: checkInDay, hour: 5, minutes: 0), checkedOut: UTCHour(day: checkInDay, hour: 7, minutes: 0), isRisky: false)

        c1 = try c1.changeToRiskyWarnAndBookATest()
        checkInsStore.save(c1)

        _ = try XCTUnwrap(checkInsStore.load())

        checkInsStore.set(CircuitBreakerApproval.yes, for: "DCJK2345")

        XCTAssertNil(checkInContext.recentlyVisitedSevereRiskyVenue.currentValue)
    }
}
