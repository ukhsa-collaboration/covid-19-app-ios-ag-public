//
// Copyright © 2021 DHSC. All rights reserved.
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
    private static var standardOptionToBookATestDuration = 14
    private var optionToBookATestDuration = standardOptionToBookATestDuration

    var cancellable: AnyCancellable?

    override func setUp() {
        super.setUp()

        encryptedStore = MockEncryptedStore()
        checkInsStore = CheckInsStore(store: encryptedStore, venueDecoder: VenueDecoder.forTests, getCachedRiskyVenueConfiguration: { RiskyVenueConfiguration(optionToBookATest: DayDuration(self.optionToBookATestDuration)) })
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
                    "isRisky" : false,
                }
            ],
            "riskApprovalTokens": {},
            "unacknowldegedRiskyVenueIds": [],
        }
        """# .data(using: .utf8)!
        checkInsStore = CheckInsStore(store: encryptedStore, venueDecoder: VenueDecoder.forTests, getCachedRiskyVenueConfiguration: { RiskyVenueConfiguration(optionToBookATest: DayDuration(14)) })

        let loadedCheckIns = try XCTUnwrap(checkInsStore.load())

        XCTAssertEqual(loadedCheckIns.count, 1)
        XCTAssertEqual(loadedCheckIns[0].venueId, venueId)
        XCTAssertEqual(loadedCheckIns[0].venueName, venueName)
        XCTAssertEqual(loadedCheckIns[0].checkedIn, checkedIn)
        XCTAssertEqual(loadedCheckIns[0].checkedOut, checkedOut)
        XCTAssertEqual(loadedCheckIns[0].isRisky, false)
        XCTAssertTrue(checkInsStore.riskyCheckIns.isEmpty)
    }

    func testLoadingRiskyCheckInData() throws {

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
                    "isRisky" : true,
                }
            ],
            "riskApprovalTokens": {},
            "unacknowldegedRiskyVenueIds": [],
        }
        """# .data(using: .utf8)!
        checkInsStore = CheckInsStore(store: encryptedStore, venueDecoder: VenueDecoder.forTests, getCachedRiskyVenueConfiguration: { RiskyVenueConfiguration(optionToBookATest: DayDuration(14)) })

        let loadedCheckIns = try XCTUnwrap(checkInsStore.load())

        XCTAssertEqual(loadedCheckIns.count, 1)
        XCTAssertEqual(loadedCheckIns[0].venueId, venueId)
        XCTAssertEqual(loadedCheckIns[0].venueName, venueName)
        XCTAssertEqual(loadedCheckIns[0].checkedIn, checkedIn)
        XCTAssertEqual(loadedCheckIns[0].checkedOut, checkedOut)
        XCTAssertEqual(loadedCheckIns[0].isRisky, true)

        XCTAssertEqual(checkInsStore.riskyCheckIns.count, 1)
        XCTAssertEqual(checkInsStore.riskyCheckIns[0].venueId, venueId)
        XCTAssertEqual(checkInsStore.riskyCheckIns[0].venueName, venueName)
        XCTAssertEqual(checkInsStore.riskyCheckIns[0].checkedIn, checkedIn)
        XCTAssertEqual(checkInsStore.riskyCheckIns[0].checkedOut, checkedOut)
        XCTAssertEqual(checkInsStore.riskyCheckIns[0].isRisky, true)
    }

    func testLoadingRiskyCheckInDataWithPostcode() throws {

        let venueId = "CDEF2345"
        let venueName = "Awesome Shop"
        let venuePostcode = "SW11ABC"
        let checkedIn = UTCHour(day: GregorianDay(year: 2020, month: 5, day: 15), hour: 5)
        let checkedOut = UTCHour(day: GregorianDay(year: 2020, month: 5, day: 15), hour: 7)

        encryptedStore.stored["checkins"] = #"""
        {
            "checkIns": [
                {
                    "venueId" : "\#(venueId)",
                    "venueName" : "\#(venueName)",
                    "venuePostcode" : "\#(venuePostcode)",
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
                    "isRisky" : true,
                }
            ],
            "riskApprovalTokens": {},
            "unacknowldegedRiskyVenueIds": [],
        }
        """# .data(using: .utf8)!
        checkInsStore = CheckInsStore(store: encryptedStore, venueDecoder: VenueDecoder.forTests, getCachedRiskyVenueConfiguration: { RiskyVenueConfiguration(optionToBookATest: DayDuration(14)) })

        let loadedCheckIns = try XCTUnwrap(checkInsStore.load())

        XCTAssertEqual(loadedCheckIns.count, 1)
        XCTAssertEqual(loadedCheckIns[0].venueId, venueId)
        XCTAssertEqual(loadedCheckIns[0].venueName, venueName)
        XCTAssertEqual(loadedCheckIns[0].venuePostcode, venuePostcode)
        XCTAssertEqual(loadedCheckIns[0].checkedIn, checkedIn)
        XCTAssertEqual(loadedCheckIns[0].checkedOut, checkedOut)
        XCTAssertEqual(loadedCheckIns[0].isRisky, true)

        XCTAssertEqual(checkInsStore.riskyCheckIns.count, 1)
        XCTAssertEqual(checkInsStore.riskyCheckIns[0].venueId, venueId)
        XCTAssertEqual(checkInsStore.riskyCheckIns[0].venueName, venueName)
        XCTAssertEqual(checkInsStore.riskyCheckIns[0].venuePostcode, venuePostcode)
        XCTAssertEqual(checkInsStore.riskyCheckIns[0].checkedIn, checkedIn)
        XCTAssertEqual(checkInsStore.riskyCheckIns[0].checkedOut, checkedOut)
        XCTAssertEqual(checkInsStore.riskyCheckIns[0].isRisky, true)
    }

    func testLoadingNotRiskyCheckInDataWithCheckedInDate() throws {
        let venueId = "CDEF2345"
        let venueName = "Awesome Shop"
        let checkedIn = UTCHour(day: GregorianDay(year: 2020, month: 5, day: 15), hour: 5)
        let checkedOut = UTCHour(day: GregorianDay(year: 2020, month: 5, day: 15), hour: 7)
        let id = UUID().uuidString

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
                    "isRisky" : false,
                    "id": "\#(id)",
                }
            ],
            "riskApprovalTokens": {},
            "unacknowldegedRiskyVenueIds": [],
        }
        """# .data(using: .utf8)!
        checkInsStore = CheckInsStore(store: encryptedStore, venueDecoder: VenueDecoder.forTests, getCachedRiskyVenueConfiguration: { RiskyVenueConfiguration(optionToBookATest: DayDuration(14)) })

        let loadedCheckIns = try XCTUnwrap(checkInsStore.load())

        XCTAssertEqual(loadedCheckIns.count, 1)
        XCTAssertEqual(loadedCheckIns[0].venueId, venueId)
        XCTAssertEqual(loadedCheckIns[0].venueName, venueName)
        XCTAssertEqual(loadedCheckIns[0].checkedIn, checkedIn)
        XCTAssertEqual(loadedCheckIns[0].checkedOut, checkedOut)
        XCTAssertEqual(loadedCheckIns[0].isRisky, false)
        XCTAssertEqual(loadedCheckIns[0].id, id)
        XCTAssertTrue(checkInsStore.riskyCheckIns.isEmpty)
    }

    func testLoadingRiskyCheckInDataWithCheckedInDate() throws {

        let venueId = "CDEF2345"
        let venueName = "Awesome Shop"
        let checkedIn = UTCHour(day: GregorianDay(year: 2020, month: 5, day: 15), hour: 5)
        let checkedOut = UTCHour(day: GregorianDay(year: 2020, month: 5, day: 15), hour: 7)
        let id = UUID().uuidString

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
                    "isRisky" : true,
                    "id": "\#(id)",
                }
            ],
            "riskApprovalTokens": {},
            "unacknowldegedRiskyVenueIds": [],
        }
        """# .data(using: .utf8)!
        checkInsStore = CheckInsStore(store: encryptedStore, venueDecoder: VenueDecoder.forTests, getCachedRiskyVenueConfiguration: { RiskyVenueConfiguration(optionToBookATest: DayDuration(14)) })

        let loadedCheckIns = try XCTUnwrap(checkInsStore.load())

        XCTAssertEqual(loadedCheckIns.count, 1)
        XCTAssertEqual(loadedCheckIns[0].venueId, venueId)
        XCTAssertEqual(loadedCheckIns[0].venueName, venueName)
        XCTAssertEqual(loadedCheckIns[0].checkedIn, checkedIn)
        XCTAssertEqual(loadedCheckIns[0].checkedOut, checkedOut)
        XCTAssertEqual(loadedCheckIns[0].id, id)
        XCTAssertEqual(loadedCheckIns[0].isRisky, true)

        XCTAssertEqual(checkInsStore.riskyCheckIns.count, 1)
        XCTAssertEqual(checkInsStore.riskyCheckIns[0].venueId, venueId)
        XCTAssertEqual(checkInsStore.riskyCheckIns[0].venueName, venueName)
        XCTAssertEqual(checkInsStore.riskyCheckIns[0].checkedIn, checkedIn)
        XCTAssertEqual(checkInsStore.riskyCheckIns[0].checkedOut, checkedOut)
        XCTAssertEqual(checkInsStore.riskyCheckIns[0].id, id)
        XCTAssertEqual(checkInsStore.riskyCheckIns[0].isRisky, true)
    }

    func testFailedToLoadInvalidCheckIns() {
        encryptedStore.stored["checkins"] = #"""
        {
        }
        """# .data(using: .utf8)!
        checkInsStore = CheckInsStore(store: encryptedStore, venueDecoder: VenueDecoder.forTests, getCachedRiskyVenueConfiguration: { RiskyVenueConfiguration(optionToBookATest: DayDuration(14)) })
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

    func testSaveCheckInSucessWithPostcode() throws {
        let now = UTCHour(year: 2020, month: 5, day: 15, hour: 10).date

        var c1 = CheckIn(venue: .randomWithPostcode(), checkedInDate: now.hoursAgo(1), isRisky: false)
        XCTAssertNotNil(c1.venuePostcode)

        let c2 = CheckIn(venue: .random(), checkedInDate: now.addHours(1), isRisky: false)
        XCTAssertNil(c2.venuePostcode)

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

        checkInsStore.updateRisk(
            [RiskyVenue(
                id: "cdjk2345",
                riskyInterval: UTCHour.riskyTimeInterval,
                messageType: .warnAndInform
            ),
             RiskyVenue(
                 id: "DCjk2345",
                 riskyInterval: UTCHour.riskyTimeInterval,
                 messageType: .warnAndInform
             )]
        )

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

        checkInsStore.updateRisk(
            [RiskyVenue(
                id: "cdjk2345",
                riskyInterval: UTCHour.riskyTimeInterval,
                messageType: .warnAndInform
            ),
             RiskyVenue(
                 id: "DCjk2345",
                 riskyInterval: UTCHour.riskyTimeInterval,
                 messageType: .warnAndInform
             )]
        )

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
        let c1 = CheckIn(venue: .random(), checkedInDate: UTCHour.before.date, isRisky: false)
        let c2 = CheckIn(venue: .random(), checkedIn: UTCHour.during, checkedOut: UTCHour.during, isRisky: false)
        let c3 = CheckIn(venue: .random(), checkedIn: UTCHour.duringLater, checkedOut: UTCHour.duringLater, isRisky: false)
        let c4 = CheckIn(venue: .random(), checkedInDate: UTCHour.after.date, isRisky: false)
        checkInsStore.save(c1)
        checkInsStore.save(c2)
        checkInsStore.save(c3)
        checkInsStore.save(c4)

        let expectedRiskyCheckIns = [
            try c2.changeToRiskyWarnAndInform(),
            try c3.changeToRiskyWarnAndInform(),
        ]

        checkInsStore.updateRisk(
            [RiskyVenue(
                id: c2.venueId,
                riskyInterval: UTCHour.riskyTimeInterval,
                messageType: .warnAndInform
            ),
             RiskyVenue(
                 id: c3.venueId,
                 riskyInterval: UTCHour.riskyTimeInterval,
                 messageType: .warnAndInform
             )]
        )
        TS.assert(checkInsStore.riskyCheckIns, equals: expectedRiskyCheckIns)
        TS.assert((checkInsStore.load() ?? []).count, equals: 4)
    }

    func testUpdateRiskyVenuesOnlyChangeIntersectingCheckins() throws {
        let venue = Venue.random()
        let c1 = CheckIn(venue: venue, checkedIn: UTCHour.before, checkedOut: UTCHour.before, isRisky: false)
        let c2 = CheckIn(venue: venue, checkedIn: UTCHour.during, checkedOut: UTCHour.during, isRisky: false)
        let c3 = CheckIn(venue: .random(), checkedIn: UTCHour.duringLater, checkedOut: UTCHour.duringLater, isRisky: false)
        let c4 = CheckIn(venue: venue, checkedInDate: UTCHour.after.date, isRisky: false)
        checkInsStore.save(c1)
        checkInsStore.save(c2)
        checkInsStore.save(c3)
        checkInsStore.save(c4)

        let expectedRiskyCheckIns = [
            try c2.changeToRiskyWarnAndInform(),
            try c3.changeToRiskyWarnAndInform(),
        ]

        checkInsStore.updateRisk(
            [RiskyVenue(
                id: c2.venueId,
                riskyInterval: UTCHour.riskyTimeInterval,
                messageType: .warnAndInform
            ),
             RiskyVenue(
                 id: c3.venueId,
                 riskyInterval: UTCHour.riskyTimeInterval,
                 messageType: .warnAndInform
             )]
        )
        TS.assert(checkInsStore.riskyCheckIns, equals: expectedRiskyCheckIns)
        TS.assert((checkInsStore.load() ?? []).count, equals: 4)
    }

    func testUpdateRiskyVenueIfCheckInInTimeIntervallAndCheckoutAfter() throws {
        let venue = Venue.random()
        let c1 = CheckIn(venue: venue, checkedIn: UTCHour.during, checkedOut: UTCHour.after, isRisky: false)
        checkInsStore.save(c1)

        let expectedRiskyCheckIns = [
            try c1.changeToRiskyWarnAndInform(),
        ]

        checkInsStore.updateRisk(
            [RiskyVenue(
                id: c1.venueId,
                riskyInterval: UTCHour.riskyTimeInterval,
                messageType: .warnAndInform
            )]
        )
        TS.assert(checkInsStore.riskyCheckIns, equals: expectedRiskyCheckIns)
    }

    func testUpdateRiskyVenueIdNotCaseSensitive() throws {
        let venue = Venue(id: "DCjk2345", organisation: .random())
        let c1 = CheckIn(venue: venue, checkedIn: UTCHour.before, checkedOut: UTCHour.during, isRisky: false)
        checkInsStore.save(c1)

        let expectedRiskyCheckIns = [
            try c1.changeToRiskyWarnAndInform(),
        ]

        checkInsStore.updateRisk(
            [RiskyVenue(
                id: "DCJK2345",
                riskyInterval: UTCHour.riskyTimeInterval,
                messageType: .warnAndInform
            )]
        )
        TS.assert(checkInsStore.riskyCheckIns, equals: expectedRiskyCheckIns)
    }

    func testUpdateRiskyVenueIfCheckInBeforeTimeIntervallAndCheckoutDuring() throws {
        let venue = Venue.random()
        let c1 = CheckIn(venue: venue, checkedIn: UTCHour.before, checkedOut: UTCHour.during, isRisky: false)
        checkInsStore.save(c1)

        let expectedRiskyCheckIns = [
            try c1.changeToRiskyWarnAndInform(),
        ]

        checkInsStore.updateRisk(
            [RiskyVenue(
                id: c1.venueId,
                riskyInterval: UTCHour.riskyTimeInterval,
                messageType: .warnAndInform
            )]
        )
        TS.assert(checkInsStore.riskyCheckIns, equals: expectedRiskyCheckIns)
    }

    func testUpdateRiskyVenueIfCheckInBeforeTimeIntervallAndCheckoutAfter() throws {
        let venue = Venue.random()
        let c1 = CheckIn(venue: venue, checkedIn: UTCHour.before, checkedOut: UTCHour.after, isRisky: false)
        checkInsStore.save(c1)

        let expectedRiskyCheckIns = [
            try c1.changeToRiskyWarnAndInform(),
        ]

        checkInsStore.updateRisk(
            [RiskyVenue(
                id: c1.venueId,
                riskyInterval: UTCHour.riskyTimeInterval,
                messageType: .warnAndInform
            )]
        )
        TS.assert(checkInsStore.riskyCheckIns, equals: expectedRiskyCheckIns)
    }

    func testUpdateRiskyVenuesNoRiskyVenue() throws {
        let c1 = CheckIn(venue: .random(), checkedInDate: UTCHour.before.date, isRisky: false)
        let c2 = CheckIn(venue: .random(), checkedIn: UTCHour.during, checkedOut: UTCHour.during, isRisky: false)
        let c3 = CheckIn(venue: .random(), checkedIn: UTCHour.duringLater, checkedOut: UTCHour.duringLater, isRisky: false)
        let c4 = CheckIn(venue: .random(), checkedInDate: UTCHour.after.date, isRisky: false)
        checkInsStore.save(c1)
        checkInsStore.save(c2)
        checkInsStore.save(c3)
        checkInsStore.save(c4)

        checkInsStore.updateRisk([])

        XCTAssertTrue(checkInsStore.riskyCheckIns.isEmpty)
        TS.assert((checkInsStore.load() ?? []).count, equals: 4)
    }

    func testUpdateRiskyVenuesSameVenueDifferentMessageType() throws {
        let c1 = CheckIn(venue: .random(), checkedInDate: UTCHour.before.date, isRisky: false)
        let c2 = CheckIn(venue: .random(), checkedInDate: UTCHour.during.date, isRisky: false)
        checkInsStore.save(c1)
        checkInsStore.save(c2)

        let expectedRiskyCheckIns = [
            try c2.changeToRiskyWarnAndBookATest(),
        ]

        checkInsStore.updateRisk(
            [RiskyVenue(
                id: c2.venueId,
                riskyInterval: UTCHour.riskyTimeInterval,
                messageType: .warnAndBookATest
            ),
             RiskyVenue(
                 id: c2.venueId,
                 riskyInterval: UTCHour.riskyTimeInterval,
                 messageType: .warnAndInform
             )]
        )
        TS.assert(checkInsStore.riskyCheckIns, equals: expectedRiskyCheckIns)
    }

    func testUpdateRiskyVenuesEmptyCheckInAndOutBefore() throws {
        let c1 = CheckIn(venue: .random(), checkedIn: UTCHour.before, checkedOut: UTCHour.before, isRisky: false)

        checkInsStore.save(c1)

        checkInsStore.updateRisk(
            [RiskyVenue(
                id: c1.venueId,
                riskyInterval: UTCHour.riskyTimeInterval,
                messageType: .warnAndBookATest
            )]
        )
        XCTAssertTrue(checkInsStore.riskyCheckIns.isEmpty)
    }

    func testUpdateRiskyVenuesEmptyCheckInAndOutAfter() throws {
        let c1 = CheckIn(venue: .random(), checkedIn: UTCHour.after, checkedOut: UTCHour.after, isRisky: false)

        checkInsStore.save(c1)

        checkInsStore.updateRisk(
            [RiskyVenue(
                id: c1.venueId,
                riskyInterval: UTCHour.riskyTimeInterval,
                messageType: .warnAndBookATest
            )]
        )
        XCTAssertTrue(checkInsStore.riskyCheckIns.isEmpty)
    }

    func testUpdateRiskyVenuesEmptyCheckInAndOutAfterWithPostcode() throws {
        let c1 = CheckIn(venue: .randomWithPostcode(), checkedIn: UTCHour.after, checkedOut: UTCHour.after, isRisky: false)

        checkInsStore.save(c1)

        checkInsStore.updateRisk(
            [RiskyVenue(
                id: c1.venueId,
                riskyInterval: UTCHour.riskyTimeInterval,
                messageType: .warnAndBookATest
            )]
        )
        XCTAssertTrue(checkInsStore.riskyCheckIns.isEmpty)

        TS.assert(checkInsStore.load(), equals: [c1])
    }

    func testCheckInWithPayloadSaveSuccess() throws {
        let payload = "UKC19TRACING:1:eyJhbGciOiJFUzI1NiIsInR5cCI6IkpXVCIsImtpZCI6IjMifQ.eyJpZCI6IjRXVDU5TTVZIiwib3BuIjoiR292ZXJubWVudCBPZmZpY2UgT2YgSHVtYW4gUmVzb3VyY2VzIn0.ZIvwm9rxiRTm4o-koafL6Bzre9pakcyae8m6_MSyvAl-CFkUgfm6gcXYn4gg5OScKZ1-XayHBGwEdps0RKXs4g"

        let (venueName, _) = try checkInsStore.checkIn(with: payload, currentDate: Date())
        XCTAssertEqual(venueName, "Government Office Of Human Resources")
    }

    func testCheckInWithInvalidPayload() throws {
        let payload = UUID().uuidString
        XCTAssertThrowsError(try checkInsStore.checkIn(with: payload, currentDate: Date()))
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

    func testCanDeleteACheckIn() throws {
        let checkIn1 = UTCHour(year: 2020, month: 5, day: 15, hour: 10, minutes: 40).date
        let checkIn2 = UTCHour(year: 2020, month: 5, day: 15, hour: 10, minutes: 50).date
        var c1 = CheckIn(venue: .random(), checkedInDate: checkIn1, isRisky: false)
        let c2 = CheckIn(venue: .random(), checkedInDate: checkIn2, isRisky: false)

        checkInsStore.save(c1)
        c1.checkedOut = c2.checkedIn
        checkInsStore.save(c2)

        let checkIns = checkInsStore.load()!

        checkInsStore.delete(checkInId: c1.id)
        TS.assert(checkInsStore.load(), equals: [checkIns[1]])
    }

    func testCanDeleteOnlyACheckInWithAnUniqueID() throws {
        let checkIn2 = UTCHour(year: 2020, month: 5, day: 15, hour: 10, minutes: 50).date
        let checkInDate1_1 = Calendar.utc.date(from: DateComponents(year: 2020, month: 5, day: 15, hour: 10, minute: 37))!
        let checkInDate1_2 = Calendar.utc.date(from: DateComponents(year: 2020, month: 5, day: 15, hour: 10, minute: 38))!
        let venue1 = Venue.random()
        var c1_1 = CheckIn(venue: venue1, checkedInDate: checkInDate1_1, isRisky: false)
        var c1_2 = CheckIn(venue: venue1, checkedInDate: checkInDate1_2, isRisky: false)
        let c2 = CheckIn(venue: .random(), checkedInDate: checkIn2, isRisky: false)

        c1_1.checkedOut = c2.checkedIn
        c1_2.checkedOut = c2.checkedIn

        checkInsStore.save(c1_1)
        checkInsStore.save(c1_2)
        checkInsStore.save(c2)

        let checkIns = checkInsStore.load()!

        checkInsStore.delete(checkInId: checkIns[0].id)
        TS.assert(checkInsStore.load(), equals: [checkIns[1], checkIns[2]])
    }

    func testLastUnacknowledgedRiskyCheckInsOnlyWarnAndInformUnacknowledged() throws {
        encryptedStore.stored["checkins"] = #"""
        {
            "checkIns": [
                {
                    "venueId" : "DCJK2345",
                    "venueName" : "venue1",
                    "checkedIn" : {
                        "day" : {
                            "year" : 2021,
                            "month" : 2,
                            "day" : 22
                        },
                        "hour" : 5,
                        "minutes": 0
                    },
                    "checkedOut" : {
                        "day" : {
                            "year" : 2021,
                            "month" : 2,
                            "day" : 22
                        },
                        "hour" : 7,
                        "minutes": 0
                    },
                    "circuitBreakerApproval" : "pending",
                    "isRisky" : true,
                    "id": "\#(UUID().uuidString)",
                    "venueMessageType": "warnAndInform",
                },
                {
                    "venueId" : "CDEF2345",
                    "venueName" : "venue2",
                    "checkedIn" : {
                        "day" : {
                            "year" : 2021,
                            "month" : 2,
                            "day" : 24
                        },
                        "hour" : 5,
                        "minutes": 0
                    },
                    "checkedOut" : {
                        "day" : {
                            "year" : 2021,
                            "month" : 2,
                            "day" : 24
                        },
                        "hour" : 7,
                        "minutes": 0
                    },
                    "circuitBreakerApproval" : "pending",
                    "isRisky" : true,
                    "id": "\#(UUID().uuidString)",
                    "venueMessageType": "warnAndInform",
                },
                {
                    "venueId" : "DCJK2346",
                    "venueName" : "venue3",
                    "checkedIn" : {
                        "day" : {
                            "year" : 2021,
                            "month" : 2,
                            "day" : 23
                        },
                        "hour" : 5,
                        "minutes": 0
                    },
                    "checkedOut" : {
                        "day" : {
                            "year" : 2021,
                            "month" : 2,
                            "day" : 23
                        },
                        "hour" : 7,
                        "minutes": 0
                    },
                    "circuitBreakerApproval" : "pending",
                    "isRisky" : true,
                    "id": "\#(UUID().uuidString)",
                    "venueMessageType": "warnAndInform",
                }
            ],
            "riskApprovalTokens": {},
            "unacknowldegedRiskyVenueIds": ["CDEF2345", "DCJK2345", "DCJK2346"],
        }
        """# .data(using: .utf8)!
        checkInsStore = CheckInsStore(store: encryptedStore, venueDecoder: VenueDecoder.forTests, getCachedRiskyVenueConfiguration: { RiskyVenueConfiguration(optionToBookATest: DayDuration(14)) })

        let loadedCheckIns = try XCTUnwrap(checkInsStore.load())
        XCTAssert(loadedCheckIns.count == 3)

        XCTAssertEqual(checkInsStore.mostRecentAndSevereUnacknowledgedRiskyCheckIn?.venueId, "CDEF2345")
    }

    func testLastUnacknowledgedRiskyCheckInsOnlyWarnAndBookATestUnacknowledged() throws {
        encryptedStore.stored["checkins"] = #"""
        {
            "checkIns": [
                {
                    "venueId" : "DCJK2345",
                    "venueName" : "venue1",
                    "checkedIn" : {
                        "day" : {
                            "year" : 2021,
                            "month" : 2,
                            "day" : 22
                        },
                        "hour" : 5,
                        "minutes": 0
                    },
                    "checkedOut" : {
                        "day" : {
                            "year" : 2021,
                            "month" : 2,
                            "day" : 22
                        },
                        "hour" : 7,
                        "minutes": 0
                    },
                    "circuitBreakerApproval" : "pending",
                    "isRisky" : true,
                    "id": "\#(UUID().uuidString)",
                    "venueMessageType": "warnAndBookATest",
                },
                {
                    "venueId" : "CDEF2345",
                    "venueName" : "venue2",
                    "checkedIn" : {
                        "day" : {
                            "year" : 2021,
                            "month" : 2,
                            "day" : 24
                        },
                        "hour" : 5,
                        "minutes": 0
                    },
                    "checkedOut" : {
                        "day" : {
                            "year" : 2021,
                            "month" : 2,
                            "day" : 24
                        },
                        "hour" : 7,
                        "minutes": 0
                    },
                    "circuitBreakerApproval" : "pending",
                    "isRisky" : true,
                    "id": "\#(UUID().uuidString)",
                    "venueMessageType": "warnAndBookATest",
                },
                {
                    "venueId" : "DCJK2346",
                    "venueName" : "venue3",
                    "checkedIn" : {
                        "day" : {
                            "year" : 2021,
                            "month" : 2,
                            "day" : 23
                        },
                        "hour" : 5,
                        "minutes": 0
                    },
                    "checkedOut" : {
                        "day" : {
                            "year" : 2021,
                            "month" : 2,
                            "day" : 23
                        },
                        "hour" : 7,
                        "minutes": 0
                    },
                    "circuitBreakerApproval" : "pending",
                    "isRisky" : true,
                    "id": "\#(UUID().uuidString)",
                    "venueMessageType": "warnAndBookATest",
                }
            ],
            "riskApprovalTokens": {},
            "unacknowldegedRiskyVenueIds": ["DCJK2346", "CDEF2345", "DCJK2345"],
        }
        """# .data(using: .utf8)!
        checkInsStore = CheckInsStore(store: encryptedStore, venueDecoder: VenueDecoder.forTests, getCachedRiskyVenueConfiguration: { RiskyVenueConfiguration(optionToBookATest: DayDuration(14)) })

        let loadedCheckIns = try XCTUnwrap(checkInsStore.load())
        XCTAssert(loadedCheckIns.count == 3)

        XCTAssertEqual(checkInsStore.mostRecentAndSevereUnacknowledgedRiskyCheckIn?.venueId, "CDEF2345")
    }

    func testLastUnacknowledgedRiskyCheckInsWarnAndBookATestPlusWarnAndInformUnacknowledged() throws {
        encryptedStore.stored["checkins"] = #"""
        {
            "checkIns": [
                {
                    "venueId" : "DCJK2345",
                    "venueName" : "venue1",
                    "checkedIn" : {
                        "day" : {
                            "year" : 2021,
                            "month" : 2,
                            "day" : 22
                        },
                        "hour" : 5,
                        "minutes": 0
                    },
                    "checkedOut" : {
                        "day" : {
                            "year" : 2021,
                            "month" : 2,
                            "day" : 22
                        },
                        "hour" : 7,
                        "minutes": 0
                    },
                    "circuitBreakerApproval" : "pending",
                    "isRisky" : true,
                    "id": "\#(UUID().uuidString)",
                    "venueMessageType": "warnAndBookATest",
                },
                {
                    "venueId" : "CDEF2345",
                    "venueName" : "venue2",
                    "checkedIn" : {
                        "day" : {
                            "year" : 2021,
                            "month" : 2,
                            "day" : 24
                        },
                        "hour" : 5,
                        "minutes": 0
                    },
                    "checkedOut" : {
                        "day" : {
                            "year" : 2021,
                            "month" : 2,
                            "day" : 24
                        },
                        "hour" : 7,
                        "minutes": 0
                    },
                    "circuitBreakerApproval" : "pending",
                    "isRisky" : true,
                    "id": "\#(UUID().uuidString)",
                    "venueMessageType": "warnAndInform",
                },
                {
                    "venueId" : "DCJK2346",
                    "venueName" : "venue3",
                    "checkedIn" : {
                        "day" : {
                            "year" : 2021,
                            "month" : 2,
                            "day" : 23
                        },
                        "hour" : 5,
                        "minutes": 0
                    },
                    "checkedOut" : {
                        "day" : {
                            "year" : 2021,
                            "month" : 2,
                            "day" : 23
                        },
                        "hour" : 7,
                        "minutes": 0
                    },
                    "circuitBreakerApproval" : "pending",
                    "isRisky" : true,
                    "id": "\#(UUID().uuidString)",
                    "venueMessageType": "warnAndBookATest",
                }
            ],
            "riskApprovalTokens": {},
            "unacknowldegedRiskyVenueIds": ["DCJK2346", "CDEF2345", "DCJK2345"],
        }
        """# .data(using: .utf8)!
        checkInsStore = CheckInsStore(store: encryptedStore, venueDecoder: VenueDecoder.forTests, getCachedRiskyVenueConfiguration: { RiskyVenueConfiguration(optionToBookATest: DayDuration(14)) })

        let loadedCheckIns = try XCTUnwrap(checkInsStore.load())
        XCTAssert(loadedCheckIns.count == 3)

        XCTAssertEqual(checkInsStore.mostRecentAndSevereUnacknowledgedRiskyCheckIn?.venueId, "DCJK2346")
    }

    func testDateOfLastRiskyCheckInStored() throws {
        encryptedStore.stored["checkins"] = #"""
        {
            "checkIns": [
                {
                    "venueId" : "DCJK2345",
                    "venueName" : "venue1",
                    "checkedIn" : {
                        "day" : {
                            "year" : 2021,
                            "month" : 2,
                            "day" : 22
                        },
                        "hour" : 5,
                        "minutes": 0
                    },
                    "checkedOut" : {
                        "day" : {
                            "year" : 2021,
                            "month" : 2,
                            "day" : 22
                        },
                        "hour" : 7,
                        "minutes": 0
                    },
                    "circuitBreakerApproval" : "pending",
                    "isRisky" : true,
                    "id": "\#(UUID().uuidString)"
                }
            ],
            "riskApprovalTokens": {},
            "unacknowldegedRiskyVenueIds": [],
        }
        """# .data(using: .utf8)!

        checkInsStore = CheckInsStore(store: encryptedStore, venueDecoder: VenueDecoder.forTests, getCachedRiskyVenueConfiguration: { RiskyVenueConfiguration(optionToBookATest: DayDuration(14)) })

        _ = try XCTUnwrap(checkInsStore.load())

        checkInsStore.saveMostRecentRiskyVenueCheckIn(
            on: GregorianDay(year: 2021, month: 2, day: 22)
        )

        XCTAssertEqual(checkInsStore.mostRecentRiskyCheckInDay, GregorianDay(year: 2021, month: 2, day: 22))
        XCTAssertEqual(checkInsStore.mostRecentRiskyVenueConfiguration?.optionToBookATest, DayDuration(14))
    }

    func testStoreMostRecentRiskyVenueCheckInDateAndConfiguration() throws {
        let now = UTCHour(year: 2021, month: 1, day: 22, hour: 8, minutes: 0)
        let c1 = CheckIn(venue: .random(), checkedInDate: now.date.addHours(-24), isRisky: false)
        var c2 = CheckIn(venue: .random(), checkedInDate: now.date, isRisky: false)
        c2 = try c2.changeToRiskyWarnAndBookATest()

        checkInsStore.save(c1)
        checkInsStore.save(c2)

        checkInsStore.saveMostRecentRiskyVenueCheckIn(on: c1.checkedIn.day)

        optionToBookATestDuration = 22

        checkInsStore.set(.yes, for: c2.venueId)

        XCTAssertEqual(c2.checkedIn.day, checkInsStore.mostRecentRiskyCheckInDay)
        XCTAssertEqual(optionToBookATestDuration, checkInsStore.mostRecentRiskyVenueConfiguration?.optionToBookATest.days)
    }

    func testDoNotStoreWarnAndInformVenueCheckInDateAndConfiguration() throws {
        let now = UTCHour(year: 2021, month: 1, day: 22, hour: 8, minutes: 0)
        let c1 = CheckIn(venue: .random(), checkedInDate: now.date.addHours(-24), isRisky: false)
        var c2 = CheckIn(venue: .random(), checkedInDate: now.date, isRisky: false)
        c2 = try c2.changeToRiskyWarnAndInform()

        checkInsStore.save(c1)
        checkInsStore.save(c2)

        checkInsStore.saveMostRecentRiskyVenueCheckIn(on: c1.checkedIn.day)

        optionToBookATestDuration = 22

        checkInsStore.set(.yes, for: c2.venueId)

        XCTAssertEqual(c1.checkedIn.day, checkInsStore.mostRecentRiskyCheckInDay)
        XCTAssertEqual(Self.standardOptionToBookATestDuration, checkInsStore.mostRecentRiskyVenueConfiguration?.optionToBookATest.days)
    }

    func testDoNotStoreOlderVenueCheckinDateAndConfiguration() throws {
        let now = UTCHour(year: 2021, month: 1, day: 22, hour: 8, minutes: 0)
        let c1 = CheckIn(venue: .random(), checkedInDate: now.date, isRisky: false)
        var c2 = CheckIn(venue: .random(), checkedInDate: now.date.addHours(-24), isRisky: false)
        c2 = try c2.changeToRiskyWarnAndBookATest()

        checkInsStore.save(c1)
        checkInsStore.save(c2)

        checkInsStore.saveMostRecentRiskyVenueCheckIn(on: c1.checkedIn.day)

        optionToBookATestDuration = 22

        checkInsStore.set(.yes, for: c2.venueId)

        XCTAssertEqual(c1.checkedIn.day, checkInsStore.mostRecentRiskyCheckInDay)
        XCTAssertEqual(Self.standardOptionToBookATestDuration, checkInsStore.mostRecentRiskyVenueConfiguration?.optionToBookATest.days)
    }

    func testRemoveMostRecentCheckInDayAndConfiguration() throws {
        let now = UTCHour(year: 2021, month: 1, day: 22, hour: 8, minutes: 0)
        let c1 = CheckIn(venue: .random(), checkedInDate: now.date, isRisky: false)
        var c2 = CheckIn(venue: .random(), checkedInDate: now.date.addHours(-24), isRisky: false)
        c2 = try c2.changeToRiskyWarnAndBookATest()

        checkInsStore.save(c1)
        checkInsStore.save(c2)

        checkInsStore.saveMostRecentRiskyVenueCheckIn(on: c1.checkedIn.day)

        optionToBookATestDuration = 22

        checkInsStore.set(.yes, for: c2.venueId)

        XCTAssertEqual(c1.checkedIn.day, checkInsStore.mostRecentRiskyCheckInDay)
        XCTAssertEqual(Self.standardOptionToBookATestDuration, checkInsStore.mostRecentRiskyVenueConfiguration?.optionToBookATest.days)

        checkInsStore.deleteMostRecentRiskyVenueCheckIn()

        XCTAssertNil(checkInsStore.mostRecentRiskyCheckInDay)
        XCTAssertNil(checkInsStore.mostRecentRiskyVenueConfiguration)
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

extension CheckIn {

    func changeToRiskyWarnAndInform() throws -> Self {
        guard !isRisky else {
            throw TestError("checkIn must not be risky")
        }

        return mutating(self) {
            $0.isRisky = true
            $0.venueMessageType = .warnAndInform
        }
    }

    func changeToRiskyWarnAndBookATest() throws -> Self {
        guard !isRisky else {
            throw TestError("checkIn must not be risky")
        }

        return mutating(self) {
            $0.isRisky = true
            $0.venueMessageType = .warnAndBookATest
        }
    }
}

extension UTCHour {
    static var before = UTCHour(day: .standard, hour: 5)
    static var during = UTCHour(day: .standard, hour: 7)
    static var duringLater = UTCHour(day: .standard, hour: 7, minutes: 30)
    static var after = UTCHour(day: .standard, hour: 9)
    static var riskyTimeInterval = DateInterval(start: UTCHour(day: .standard, hour: 6).date, end: UTCHour(day: .standard, hour: 8).date)

    init(year: Int, month: Int, day: Int, hour: Int) {
        self.init(year: year, month: month, day: day, hour: hour, minutes: 0)
    }

    init(day: GregorianDay, hour: Int) {
        self.init(day: day, hour: hour, minutes: 0)
    }
}

extension GregorianDay {
    static var standard = GregorianDay(year: 2020, month: 5, day: 5)
}
