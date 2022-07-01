//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation

struct LocalCovidStatsHandler: RequestHandler {
    var paths = ["/distribution/v1/local-covid-stats-daily"]

    var dataProvider: MockDataProvider

    var response: Result<HTTPResponse, HTTPRequestError> {
        let direction = MockDataProvider.covidStatsDirection[dataProvider.localCovidStatsDirection]
        let localAuthorityId = dataProvider.localCovidStatsLAId
        let localAuthorityResponse: String

        let dailyPositiveCases = dataProvider.peopleTestedPositiveHasData ? 105 : nil
        let weeklyPositiveCases = dataProvider.peopleTestedPositiveHasData ? -771 : nil

        let localAuthorityCasePer100k = dataProvider.casesPer100KHasData ? 289.5 : nil
        let countryCasesPer100k = dataProvider.casesPer100KHasData ? 510.8 : nil

        if localAuthorityId.isEmpty {
            localAuthorityResponse = ""
        } else {
            localAuthorityResponse = #"""
            "\#(localAuthorityId)": {
                "name": "LA name",
                \#(value(named: "newCasesByPublishDateRollingSum", content: weeklyPositiveCases)),
                "newCasesByPublishDateChange": 207,
                "newCasesByPublishDateDirection": "\#(direction)",
                \#(value(named: "newCasesByPublishDate", content: dailyPositiveCases)),
                "newCasesByPublishDateChangePercentage": 36.7,
                \#(value(named: "newCasesBySpecimenDateRollingRate", content: localAuthorityCasePer100k))
            }
            """#
        }
        let response = HTTPResponse.ok(with: .json(#"""
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
                \#(value(named: "newCasesBySpecimenDateRollingRate", content: countryCasesPer100k))
            },
            "wales": {
                "newCasesBySpecimenDateRollingRate": null
            },
            "lowerTierLocalAuthorities": {
                \#(localAuthorityResponse)
            }
        }
        """#))
        return Result.success(response)
    }
}
