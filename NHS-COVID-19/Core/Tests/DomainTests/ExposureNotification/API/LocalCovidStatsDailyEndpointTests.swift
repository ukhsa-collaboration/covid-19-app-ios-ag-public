//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import TestSupport
import XCTest
@testable import Domain

class LocalCovidStatsDailyEndpointTests: XCTestCase {

    typealias StatsValue = LocalCovidStatsDaily.LocalAuthorityStats.Value
    typealias Direction = LocalCovidStatsDaily.Direction

    private let endpoint = LocalCovidStatsDailyEndpoint()

    func testRequest() throws {
        let expected = HTTPRequest.get("/distribution/v1/local-covid-stats-daily")

        let actual = try endpoint.request(for: ())

        TS.assert(actual, equals: expected)
    }

    func testResponse() throws {
        let response = HTTPResponse.ok(with: .json(localCovidStatsDailyPayload))

        let formatter = ISO8601DateFormatter()

        let date = { (string: String) throws -> Date in
            try XCTUnwrap(formatter.date(from: string))
        }

        let day = GregorianDay(year: 2021, month: 11, day: 18)
        let dayOne = GregorianDay(year: 2021, month: 11, day: 13)
        let expected = try LocalCovidStatsDaily(
            lastFetch: date("2021-11-15T21:59:00Z"),
            england: LocalCovidStatsDaily.CountryStats(newCasesBySpecimenDateRollingRate: 510.8, lastUpdate: dayOne),
            wales: LocalCovidStatsDaily.CountryStats(newCasesBySpecimenDateRollingRate: nil, lastUpdate: dayOne),
            lowerTierLocalAuthorities: [
                LocalAuthorityId("E06000037"): LocalCovidStatsDaily.LocalAuthorityStats(
                    id: LocalAuthorityId("E06000037"),
                    name: "West Berkshire",
                    newCasesByPublishDateRollingSum: StatsValue(value: -771, lastUpdate: day),
                    newCasesByPublishDateChange: StatsValue(value: 207, lastUpdate: day),
                    newCasesByPublishDateDirection: StatsValue(value: .up, lastUpdate: day),
                    newCasesByPublishDate: StatsValue(value: 105, lastUpdate: day),
                    newCasesByPublishDateChangePercentage: StatsValue(value: 36.7, lastUpdate: day),
                    newCasesBySpecimenDateRollingRate: StatsValue(value: 289.5, lastUpdate: dayOne)
                ),
                LocalAuthorityId("E08000035"): LocalCovidStatsDaily.LocalAuthorityStats(
                    id: LocalAuthorityId("E08000035"),
                    name: "Leeds",
                    newCasesByPublishDateRollingSum: StatsValue(value: nil, lastUpdate: day),
                    newCasesByPublishDateChange: StatsValue(value: nil, lastUpdate: day),
                    newCasesByPublishDateDirection: StatsValue(value: nil, lastUpdate: day),
                    newCasesByPublishDate: StatsValue(value: nil, lastUpdate: day),
                    newCasesByPublishDateChangePercentage: StatsValue(value: nil, lastUpdate: day),
                    newCasesBySpecimenDateRollingRate: StatsValue(value: nil, lastUpdate: dayOne)
                ),
            ]
        )
        TS.assert(try endpoint.parse(response), equals: expected)
    }
}

private let localCovidStatsDailyPayload = """
{
    "lastFetch": "2021-11-15T21:59:00Z",
    "metadata": {
        "england": {
            "newCasesBySpecimenDateRollingRate": {
                "lastUpdate": "2021-11-13"
            }
        },
        "wales": {
            "newCasesBySpecimenDateRollingRate": {
                "lastUpdate": "2021-11-13"
            }
        },
        "lowerTierLocalAuthorities": {
            "newCasesByPublishDate": {
                "lastUpdate": "2021-11-18"
            },
            "newCasesByPublishDateChangePercentage": {
                "lastUpdate": "2021-11-18"
            },
            "newCasesByPublishDateChange": {
                "lastUpdate": "2021-11-18"
            },
            "newCasesByPublishDateRollingSum": {
                "lastUpdate": "2021-11-18"
            },
            "newCasesByPublishDateDirection": {
                "lastUpdate": "2021-11-18"
            },
            "newCasesBySpecimenDateRollingRate": {
                "lastUpdate": "2021-11-13"
            }
        }
    },
    "england": {
        "newCasesBySpecimenDateRollingRate": 510.8
    },
    "wales": {
        "newCasesBySpecimenDateRollingRate": null
    },
    "lowerTierLocalAuthorities": {
        "E06000037": {
            "name": "West Berkshire",
            "newCasesByPublishDateRollingSum": -771,
            "newCasesByPublishDateChange": 207,
            "newCasesByPublishDateDirection": "UP",
            "newCasesByPublishDate": 105,
            "newCasesByPublishDateChangePercentage": 36.7,
            "newCasesBySpecimenDateRollingRate": 289.5
        },
        "E08000035": {
            "name": "Leeds",
            "newCasesByPublishDateRollingSum": null,
            "newCasesByPublishDateChange": null,
            "newCasesByPublishDateDirection": null,
            "newCasesByPublishDate": null,
            "newCasesByPublishDateChangePercentage": null,
            "newCasesBySpecimenDateRollingRate": null
        }
    }
}
"""
