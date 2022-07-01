//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation

struct LocalCovidStatsDailyEndpoint: HTTPEndpoint {

    func request(for input: Void) throws -> HTTPRequest {
        .get("/distribution/v1/local-covid-stats-daily")
    }

    func parse(_ response: HTTPResponse) throws -> LocalCovidStatsDaily {
        let decoder = JSONDecoder()
        decoder.dateDecodingStrategy = .appNetworking
        let payload = try decoder.decode(Payload.self, from: response.body.content)
        return try LocalCovidStatsDaily(payload)
    }
}

private struct Payload: Codable {
    let lastFetch: Date
    let metadata: Metadata
    let england: NewCasesBySpecimenDateRollingRate
    let wales: NewCasesBySpecimenDateRollingRate
    let lowerTierLocalAuthorities: [String: LowerTierLocalAuthorities]
}

private struct NewCasesBySpecimenDateRollingRate: Codable {
    let newCasesBySpecimenDateRollingRate: Double?
}

private struct LowerTierLocalAuthorities: Codable {
    let name: String
    var newCasesByPublishDateRollingSum: Int?
    var newCasesByPublishDateChange: Int?
    var newCasesByPublishDateDirection: Direction?
    var newCasesByPublishDate: Int?
    var newCasesByPublishDateChangePercentage: Double?
    var newCasesBySpecimenDateRollingRate: Double?
}

private struct Metadata: Codable {
    let england: NewCases
    let wales: NewCases
    let lowerTierLocalAuthorities: [String: Updated]
}

private enum Direction: String, Codable {
    case up = "UP"
    case down = "DOWN"
    case same = "SAME"
}

private struct Updated: Codable {
    let lastUpdate: GregorianDay

    enum CodingKeys: String, CodingKey {
        case lastUpdate
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        let value = try container.decode(String.self, forKey: .lastUpdate)
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = .current
        dateFormatter.dateFormat = "yyyy-MM-dd"
        if let date = dateFormatter.date(from: value) {
            lastUpdate = GregorianDay(date: date, timeZone: .current)
        } else {
            throw DecodingError.dataCorruptedError(forKey: .lastUpdate, in: container, debugDescription: "Date couldn't be created from string")
        }
    }

}

private struct NewCases: Codable {
    let newCasesBySpecimenDateRollingRate: Updated
}

enum LocalCovidStatsDailyError: Error {
    case mappingError(String)
}

private extension LocalCovidStatsDaily {
    init(_ payload: Payload) throws {
        lastFetch = payload.lastFetch
        england = CountryStats(newCasesBySpecimenDateRollingRate: payload.england.newCasesBySpecimenDateRollingRate, lastUpdate: payload.metadata.england.newCasesBySpecimenDateRollingRate.lastUpdate)
        wales = CountryStats(newCasesBySpecimenDateRollingRate: payload.wales.newCasesBySpecimenDateRollingRate, lastUpdate: payload.metadata.wales.newCasesBySpecimenDateRollingRate.lastUpdate)

        lowerTierLocalAuthorities = try Dictionary(uniqueKeysWithValues: payload.lowerTierLocalAuthorities.map { key, value in
            let localAuthorityId = LocalAuthorityId(key)
            let localAuthorityStats = try LocalAuthorityStats(id: localAuthorityId, stats: value, localAuthoritiesMetadata: payload.metadata.lowerTierLocalAuthorities)
            return (localAuthorityId, localAuthorityStats)
        })
    }
}

private extension LocalCovidStatsDaily.Direction {
    init?(rawValue: Direction?) {
        switch rawValue {
        case .up: self = .up
        case .down: self = .down
        case .same: self = .same
        default: return nil
        }
    }
}

private extension LocalCovidStatsDaily.LocalAuthorityStats {
    typealias StatsValue = LocalCovidStatsDaily.LocalAuthorityStats.Value
    typealias Direction = LocalCovidStatsDaily.Direction

    init(id: LocalAuthorityId, stats: LowerTierLocalAuthorities, localAuthoritiesMetadata metadata: [String: Updated]) throws {
        self.id = id
        name = stats.name

        if let lastUpdate = metadata["newCasesByPublishDateRollingSum"]?.lastUpdate {
            newCasesByPublishDateRollingSum = StatsValue(
                value: stats.newCasesByPublishDateRollingSum,
                lastUpdate: lastUpdate
            )
        } else {
            throw LocalCovidStatsDailyError.mappingError("newCasesByPublishDateRollingSum")
        }

        if let lastUpdate = metadata["newCasesByPublishDateChange"]?.lastUpdate {
            newCasesByPublishDateChange = StatsValue(
                value: stats.newCasesByPublishDateChange,
                lastUpdate: lastUpdate
            )
        } else {
            throw LocalCovidStatsDailyError.mappingError("newCasesByPublishDateChange")
        }

        if let lastUpdate = metadata["newCasesByPublishDateDirection"]?.lastUpdate {
            newCasesByPublishDateDirection = StatsValue(
                value: Direction(rawValue: stats.newCasesByPublishDateDirection),
                lastUpdate: lastUpdate
            )
        } else {
            throw LocalCovidStatsDailyError.mappingError("newCasesByPublishDateDirection")
        }

        if let lastUpdate = metadata["newCasesByPublishDate"]?.lastUpdate {
            newCasesByPublishDate = StatsValue(
                value: stats.newCasesByPublishDate,
                lastUpdate: lastUpdate
            )
        } else {
            throw LocalCovidStatsDailyError.mappingError("newCasesByPublishDate")
        }

        if let lastUpdate = metadata["newCasesByPublishDateChangePercentage"]?.lastUpdate {
            newCasesByPublishDateChangePercentage = StatsValue(
                value: stats.newCasesByPublishDateChangePercentage,
                lastUpdate: lastUpdate
            )
        } else {
            throw LocalCovidStatsDailyError.mappingError("newCasesByPublishDateChangePercentage")
        }

        if let lastUpdate = metadata["newCasesBySpecimenDateRollingRate"]?.lastUpdate {
            newCasesBySpecimenDateRollingRate = StatsValue(
                value: stats.newCasesBySpecimenDateRollingRate,
                lastUpdate: lastUpdate
            )
        } else {
            throw LocalCovidStatsDailyError.mappingError("newCasesBySpecimenDateRollingRate")
        }

    }
}
