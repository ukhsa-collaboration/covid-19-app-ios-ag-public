//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Scenarios
import TestSupport
import XCTest
@testable import Domain

class CheckInsManagerTests: XCTestCase {
    var checkInsManager: CheckInsManager!
    
    var riskyVenues = [RiskyVenue]()
    
    func fetchRiskyVenues() -> AnyPublisher<[RiskyVenue], NetworkRequestError> {
        Result.success(riskyVenues).publisher.eraseToAnyPublisher()
    }
    
    var checkIns: [CheckIn] = []
    
    func save(_ checkIn: CheckIn) {
        checkIns.append(checkIn)
    }
    
    var deletedCheckinsBefore: UTCHour?
    
    var riskyvenueIds: [String]?
    
    override func setUp() {
        checkIns = []
        
        checkInsManager = CheckInsManager(
            checkInsStoreLoad: { self.checkIns },
            checkInsStoreDeleteExpired: { self.deletedCheckinsBefore = $0 },
            updateRisk: {
                self.riskyvenueIds = $0
            },
            fetchRiskyVenues: fetchRiskyVenues
        )
        
        addTeardownBlock {
            self.checkInsManager = nil
        }
    }
    
    func testNoRiskyCheckInsWhenThereIsNoCheckIns() throws {
        try checkInsManager.evaluateVenuesRisk().await().get()
        let riskyvenueIds = try XCTUnwrap(self.riskyvenueIds)
        XCTAssertTrue(riskyvenueIds.isEmpty)
    }
    
    func testNoRiskyCheckInsWhenNoMatchingvenueIds() throws {
        let v1 = Venue.random()
        let v2 = Venue.random()
        let c1 = CheckIn(venue: v1, checkedIn: .during, checkedOut: .during, isRisky: false)
        let c2 = CheckIn(venue: v2, checkedIn: .during, checkedOut: .during, isRisky: false)
        save(c1)
        save(c2)
        
        riskyVenues = [
            RiskyVenue(id: .random(), riskyInterval: UTCHour.riskyTimeInterval),
        ]
        try checkInsManager.evaluateVenuesRisk().await().get()
        let riskyvenueIds = try XCTUnwrap(self.riskyvenueIds)
        XCTAssertTrue(riskyvenueIds.isEmpty)
    }
    
    func testHavingRiskyCheckInsWhenThereAreMatchingLowercasedvenueIdsAndRiskyInterval() throws {
        let v1 = mutating(Venue.random()) { $0.id = $0.id.uppercased() }
        let v2 = Venue.random()
        let c1 = CheckIn(venue: v1, checkedIn: .during, checkedOut: .during, isRisky: false)
        let c2 = CheckIn(venue: v2, checkedIn: .during, checkedOut: .during, isRisky: false)
        save(c1)
        save(c2)
        
        riskyVenues = [
            RiskyVenue(id: v1.id.lowercased(), riskyInterval: UTCHour.riskyTimeInterval),
        ]
        try checkInsManager.evaluateVenuesRisk().await().get()
        let riskyvenueIds = try XCTUnwrap(self.riskyvenueIds)
        TS.assert(riskyvenueIds, equals: [v1.id.lowercased()])
    }
    
    func testIfCheckInAndCheckOutIsInRiskyTimeInterval() throws {
        let v1 = Venue.random()
        let checkIn = CheckIn(venue: v1, checkedIn: .during, checkedOut: .during, isRisky: false)
        
        save(checkIn)
        
        riskyVenues = [
            RiskyVenue(id: v1.id, riskyInterval: UTCHour.riskyTimeInterval),
        ]
        
        try checkInsManager.evaluateVenuesRisk().await().get()
        let riskyvenueIds = try XCTUnwrap(self.riskyvenueIds)
        TS.assert(riskyvenueIds, equals: [v1.id])
    }
    
    func testIfCheckInIsInRiskyTimeIntervalAndCheckOutIsAfter() throws {
        let v1 = Venue.random()
        let checkIn = CheckIn(venue: v1, checkedIn: .during, checkedOut: .after, isRisky: false)
        save(checkIn)
        
        riskyVenues = [
            RiskyVenue(id: v1.id, riskyInterval: UTCHour.riskyTimeInterval),
        ]
        
        try checkInsManager.evaluateVenuesRisk().await().get()
        let riskyvenueIds = try XCTUnwrap(self.riskyvenueIds)
        TS.assert(riskyvenueIds, equals: [v1.id])
    }
    
    func testIfCheckInIsBeforeRiskyTimeIntervalAndCheckOutIsIn() throws {
        let v1 = Venue.random()
        let checkIn = CheckIn(venue: v1, checkedIn: .before, checkedOut: .during, isRisky: false)
        save(checkIn)
        
        riskyVenues = [
            RiskyVenue(id: v1.id, riskyInterval: UTCHour.riskyTimeInterval),
        ]
        
        try checkInsManager.evaluateVenuesRisk().await().get()
        let riskyvenueIds = try XCTUnwrap(self.riskyvenueIds)
        TS.assert(riskyvenueIds, equals: [v1.id])
    }
    
    func testIfCheckInIsBeforeRiskyTimeIntervalAndCheckOutIsAfter() throws {
        let v1 = Venue.random()
        let checkIn = CheckIn(venue: v1, checkedIn: .before, checkedOut: .after, isRisky: false)
        save(checkIn)
        
        riskyVenues = [
            RiskyVenue(id: v1.id, riskyInterval: UTCHour.riskyTimeInterval),
        ]
        
        try checkInsManager.evaluateVenuesRisk().await().get()
        let riskyvenueIds = try XCTUnwrap(self.riskyvenueIds)
        TS.assert(riskyvenueIds, equals: [v1.id])
    }
    
    func testIfCheckInIsBeforeRiskyTimeIntervalAndCheckOutIsBefore() throws {
        let v1 = Venue.random()
        let checkIn = CheckIn(venue: v1, checkedIn: .before, checkedOut: .before, isRisky: false)
        save(checkIn)
        
        riskyVenues = [
            RiskyVenue(id: v1.id, riskyInterval: UTCHour.riskyTimeInterval),
        ]
        
        try checkInsManager.evaluateVenuesRisk().await().get()
        let riskyvenueIds = try XCTUnwrap(self.riskyvenueIds)
        XCTAssertTrue(riskyvenueIds.isEmpty)
    }
    
    func testIfCheckInIsAfterRiskyTimeIntervalAndCheckOutIsAfter() throws {
        let v1 = Venue.random()
        let checkIn = CheckIn(venue: v1, checkedIn: .after, checkedOut: .after, isRisky: false)
        save(checkIn)
        
        riskyVenues = [
            RiskyVenue(id: v1.id, riskyInterval: UTCHour.riskyTimeInterval),
        ]
        
        try checkInsManager.evaluateVenuesRisk().await().get()
        let riskyvenueIds = try XCTUnwrap(self.riskyvenueIds)
        XCTAssertTrue(riskyvenueIds.isEmpty)
    }
    
}

extension CheckIn {
    
    func changeToRisky() throws -> Self {
        guard !isRisky else {
            throw TestError("checkIn must not be risky")
        }
        
        return mutating(self) {
            $0.isRisky = true
        }
    }
}

extension UTCHour {
    static var before = UTCHour(day: .standard, hour: 5)
    static var during = UTCHour(day: .standard, hour: 7)
    static var after = UTCHour(day: .standard, hour: 9)
    static var riskyTimeInterval = DateInterval(start: UTCHour(day: .standard, hour: 6).date, end: UTCHour(day: .standard, hour: 8).date)
}

extension GregorianDay {
    static var standard = GregorianDay(year: 2020, month: 5, day: 5)
}
