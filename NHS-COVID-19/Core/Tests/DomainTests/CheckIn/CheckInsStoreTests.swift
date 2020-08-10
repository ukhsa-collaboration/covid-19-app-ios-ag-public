//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Scenarios
import TestSupport
import XCTest
@testable import Domain

class CheckInsStoreTests: XCTestCase {
    
    private var encryptedStore: MockEncryptedStore!
    private var checkInsStore: CheckInsStore!
    
    var cancellable: AnyCancellable?
    
    override func setUp() {
        super.setUp()
        
        encryptedStore = MockEncryptedStore()
        checkInsStore = CheckInsStore(store: encryptedStore, venueDecoder: .forTests)
    }
    
    func testLoadingNotRiskyCheckInData() throws {
        let venueId = "CDEF2345"
        let venueName = "Awesome Shop"
        let checkedIn = UTCHour(day: GregorianDay(year: 2020, month: 5, day: 15), hour: 5)
        let checkedOut = UTCHour(day: GregorianDay(year: 2020, month: 5, day: 15), hour: 7)
        
        encryptedStore.stored["checkins"] = #"""
        {
            "checkIns": [
                {
                    "venueId" : "\#(venueId)",
                    "venueName" : "\#(venueName)",
                    "checkedIn" : {
                        "day" : {
                            "year" : 2020,
                            "month" : 5,
                            "day" : 15
                        },
                        "hour" : 5,
                        "minutes": 0
                    },
                    "checkedOut" : {
                        "day" : {
                            "year" : 2020,
                            "month" : 5,
                            "day" : 15
                        },
                        "hour" : 7,
                        "minutes": 0
                    },
                    "circuitBreakerApproval" : "pending",
                    "isRisky" : false
                }
            ],
            "riskApprovalTokens": {},
            "unacknowldegedRiskyVenueIds": [],
        }
        """# .data(using: .utf8)!
        checkInsStore = CheckInsStore(store: encryptedStore, venueDecoder: .forTests)
        
        let expectedCheckIns = [
            CheckIn(
                venueId: venueId,
                venueName: venueName,
                checkedIn: checkedIn,
                checkedOut: checkedOut,
                isRisky: false
            ),
        ]
        
        TS.assert(expectedCheckIns, equals: checkInsStore.load())
        XCTAssertTrue(checkInsStore.riskyCheckIns.isEmpty)
    }
    
    func testLoadingRiskyCheckInData() throws {
        
        let venueId = "CDEF2345"
        let venueName = "Awesome Shop"
        let checkInDate = UTCHour(day: GregorianDay(year: 2020, month: 5, day: 15), hour: 5)
        let checkOutDate = UTCHour(day: GregorianDay(year: 2020, month: 5, day: 15), hour: 7)
        
        encryptedStore.stored["checkins"] = #"""
        {
            "checkIns": [
                {
                    "venueId" : "\#(venueId)",
                    "venueName" : "\#(venueName)",
                    "checkedIn" : {
                        "day" : {
                            "year" : 2020,
                            "month" : 5,
                            "day" : 15
                        },
                        "hour" : 5,
                        "minutes": 0
                    },
                    "checkedOut" : {
                        "day" : {
                            "year" : 2020,
                            "month" : 5,
                            "day" : 15
                        },
                        "hour" : 7,                        
                        "minutes": 0
                    },
                    "circuitBreakerApproval" : "pending",
                    "isRisky" : true
                }
            ],
            "riskApprovalTokens": {},
            "unacknowldegedRiskyVenueIds": [],
        }
        """# .data(using: .utf8)!
        checkInsStore = CheckInsStore(store: encryptedStore, venueDecoder: .forTests)
        
        let expectedCheckIns = [
            CheckIn(
                venueId: venueId,
                venueName: venueName,
                checkedIn: checkInDate,
                checkedOut: checkOutDate,
                isRisky: true
            ),
        ]
        
        TS.assert(expectedCheckIns, equals: checkInsStore.load())
        TS.assert(expectedCheckIns, equals: checkInsStore.riskyCheckIns)
    }
    
    func testFailedToLoadInvalidCheckIns() {
        encryptedStore.stored["checkins"] = #"""
        {
        }
        """# .data(using: .utf8)!
        checkInsStore = CheckInsStore(store: encryptedStore, venueDecoder: .forTests)
        XCTAssertNil(checkInsStore.load())
    }
    
    func testSaveCheckInSucess() throws {
        let now = UTCHour(year: 2020, month: 5, day: 15, hour: 10).date
        var c1 = CheckIn(venue: .random(), checkedInDate: now.hoursAgo(1), isRisky: false)
        let c2 = CheckIn(venue: .random(), checkedInDate: now.addHours(1), isRisky: false)
        
        checkInsStore.save(c1)
        TS.assert(checkInsStore.load(), equals: [c1])
        
        checkInsStore.save(c2)
        c1.checkedOut = UTCHour(roundedUpToQuarter: c2.checkedIn.date)
        TS.assert(checkInsStore.load(), equals: [c1, c2])
    }
    
    func testDeleteExpiredCheckIns() throws {
        let now = UTCHour(year: 2020, month: 5, day: 15, hour: 10).date
        let c1 = CheckIn(venue: .random(), checkedInDate: now.hoursAgo(3), isRisky: false)
        let c2 = CheckIn(venue: .random(), checkedInDate: now.hoursAgo(2), isRisky: false)
        var c3 = CheckIn(venue: .random(), checkedInDate: now.addHours(2), isRisky: false)
        let c4 = CheckIn(venue: .random(), checkedInDate: now.addHours(3), isRisky: false)
        checkInsStore.save(c1)
        checkInsStore.save(c2)
        checkInsStore.save(c3)
        checkInsStore.save(c4)
        checkInsStore.deleteExpired(before: UTCHour(roundedDownToQuarter: now))
        c3.checkedOut = UTCHour(roundedUpToQuarter: c4.checkedIn.date)
        TS.assert(checkInsStore.load(), equals: [c3, c4])
    }
    
    func testUpdateRiskyVenues() throws {
        let now = UTCHour(year: 2020, month: 5, day: 15, hour: 10).date
        let c1 = CheckIn(venue: .random(), checkedInDate: now.hoursAgo(2), isRisky: false)
        let c2 = CheckIn(venue: .random(), checkedInDate: now.hoursAgo(1), isRisky: false)
        let c3 = CheckIn(venue: .random(), checkedInDate: now.addHours(1), isRisky: false)
        let c4 = CheckIn(venue: .random(), checkedInDate: now.addHours(2), isRisky: false)
        checkInsStore.save(c1)
        checkInsStore.save(c2)
        checkInsStore.save(c3)
        checkInsStore.save(c4)
        
        checkInsStore.updateRisk(["CDJK2345", "DCJK2345"])
        
        let checkIns = try XCTUnwrap(checkInsStore.load())
        for checkIn in checkIns {
            if checkIn.venueId == "CDEF2345" {
                XCTAssertFalse(checkIn.isRisky)
            }
            
            if checkIn.venueId == "CDJK2345" {
                XCTAssertTrue(checkIn.isRisky)
            }
            
            if checkIn.venueId == "DCJK2345" {
                XCTAssertTrue(checkIn.isRisky)
            }
            
            if checkIn.venueId == "JK682345" {
                XCTAssertFalse(checkIn.isRisky)
            }
        }
    }
    
    func testUpdateRiskyVenuesWithLowercasedIDs() throws {
        let now = UTCHour(year: 2020, month: 5, day: 15, hour: 10).date
        let c1 = CheckIn(venue: .random(), checkedInDate: now.hoursAgo(2), isRisky: false)
        let c2 = CheckIn(venue: .random(), checkedInDate: now.hoursAgo(1), isRisky: false)
        let c3 = CheckIn(venue: .random(), checkedInDate: now.addHours(1), isRisky: false)
        let c4 = CheckIn(venue: .random(), checkedInDate: now.addHours(2), isRisky: false)
        checkInsStore.save(c1)
        checkInsStore.save(c2)
        checkInsStore.save(c3)
        checkInsStore.save(c4)
        
        checkInsStore.updateRisk(["cdjk2345", "DCjk2345"])
        
        let checkIns = try XCTUnwrap(checkInsStore.load())
        for checkIn in checkIns {
            if checkIn.venueId == "CDEF2345" {
                XCTAssertFalse(checkIn.isRisky)
            }
            
            if checkIn.venueId == "CDJK2345" {
                XCTAssertTrue(checkIn.isRisky)
            }
            
            if checkIn.venueId == "DCJK2345" {
                XCTAssertTrue(checkIn.isRisky)
            }
            
            if checkIn.venueId == "JK682345" {
                XCTAssertFalse(checkIn.isRisky)
            }
        }
    }
    
    func testUpdateRiskyVenuesTriggerPublishedProperty() throws {
        let now = UTCHour(year: 2020, month: 5, day: 15, hour: 10).date
        let c1 = CheckIn(venue: .random(), checkedInDate: now.hoursAgo(48), isRisky: false)
        let c2 = CheckIn(venue: .random(), checkedInDate: now.hoursAgo(24), isRisky: false)
        let c3 = CheckIn(venue: .random(), checkedInDate: now.addHours(24), isRisky: false)
        let c4 = CheckIn(venue: .random(), checkedInDate: now.addHours(48), isRisky: false)
        checkInsStore.save(c1)
        checkInsStore.save(c2)
        checkInsStore.save(c3)
        checkInsStore.save(c4)
        
        let expectedRiskyCheckIns = [
            try c2.changeToRisky(),
            try c3.changeToRisky(),
        ]
        
        checkInsStore.updateRisk([c2.venueId, c3.venueId])
        TS.assert(checkInsStore.riskyCheckIns, equals: expectedRiskyCheckIns)
    }
    
    func testCheckInWithPayloadSaveSuccess() throws {
        let payload = "UKC19TRACING:1:eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjMifQ.eyJpZCI6IjRXVDU5TTVZIiwib3BuIjoiR292ZXJubWVudCBPZmZpY2UgT2YgSHVtYW4gUmVzb3VyY2VzIn0.ZIvwm9rxiRTm4o-koafL6Bzre9pakcyae8m6_MSyvAl-CFkUgfm6gcXYn4gg5OScKZ1-XayHBGwEdps0RKXs4g"
        
        let (venueName, _) = try checkInsStore.checkIn(with: payload)
        XCTAssertEqual(venueName, "Government Office Of Human Resources")
    }
    
    func testCheckInWithInvalidPayload() throws {
        let payload = UUID().uuidString
        XCTAssertThrowsError(try checkInsStore.checkIn(with: payload))
    }
    
    func testCheckInAutomaticallyCheckOutAtMidnight() {
        let now = UTCHour(year: 2020, month: 5, day: 15, hour: 10).date
        let c1 = CheckIn(venue: .random(), checkedInDate: now)
        let expectedcheckedOut = UTCHour(roundedDownToQuarter: LocalDay(year: 2020, month: 5, day: 16, timeZone: .current).startOfDay)
        XCTAssertEqual(c1.checkedOut, expectedcheckedOut)
    }
    
    func testCheckInDoesntModifyPastCheckOut() {
        let now = UTCHour(year: 2020, month: 5, day: 15, hour: 10).date
        let c1 = CheckIn(venue: .random(), checkedInDate: now, isRisky: false)
        let c2 = CheckIn(venue: .random(), checkedInDate: LocalDay(date: now, timeZone: .current).advanced(by: 3).startOfDay, isRisky: false)
        checkInsStore.save(c1)
        checkInsStore.save(c2)
        TS.assert(checkInsStore.load(), equals: [c1, c2])
    }
    
    func testCanDeleteLatestWithOneCheckin() {
        let now = UTCHour(year: 2020, month: 5, day: 15, hour: 10).date
        let c1 = CheckIn(venue: .random(), checkedInDate: now, isRisky: false)
        checkInsStore.save(c1)
        checkInsStore.deleteLatest()
        XCTAssertNil(checkInsStore.load())
    }
    
    func testCanDeleteLatestWithMoreThanOneCheckin() {
        let now = UTCHour(year: 2020, month: 5, day: 15, hour: 10).date
        var c1 = CheckIn(venue: .random(), checkedInDate: now, isRisky: false)
        let c2 = CheckIn(venue: .random(), checkedInDate: now, isRisky: false)
        
        checkInsStore.save(c1)
        c1.checkedOut = c2.checkedIn
        checkInsStore.save(c2)
        
        checkInsStore.deleteLatest()
        c1.checkedOut = UTCHour(roundedUpToQuarter: c2.checkedIn.date)
        TS.assert(checkInsStore.load(), equals: [c1])
    }
    
    func testDeleteLatestDoesNothingWithNoCheckins() throws {
        XCTAssertNil(checkInsStore.load())
        checkInsStore.deleteLatest()
        XCTAssertNil(checkInsStore.load())
    }
}

extension Date {
    
    func addHours(_ numMinutes: Double) -> Date {
        addingTimeInterval(60 * 60 * numMinutes)
    }
    
    func hoursAgo(_ numMinutes: Double) -> Date {
        addHours(-numMinutes)
    }
    
}

extension UTCHour {
    init(year: Int, month: Int, day: Int, hour: Int) {
        self.init(year: year, month: month, day: day, hour: hour, minutes: 0)
    }
    
    init(day: GregorianDay, hour: Int) {
        self.init(day: day, hour: hour, minutes: 0)
    }
}
