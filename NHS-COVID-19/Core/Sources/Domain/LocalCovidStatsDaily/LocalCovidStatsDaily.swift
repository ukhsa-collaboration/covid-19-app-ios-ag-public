//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation

public struct LocalCovidStatsDaily: Equatable {
    public let lastFetch: Date
    public let england: CountryStats
    public let wales: CountryStats
    public let lowerTierLocalAuthorities: [LocalAuthorityId: LocalAuthorityStats]
}

extension LocalCovidStatsDaily {
    public struct NewCasesBySpecimenDateRollingRate: Codable {
        public let newCasesBySpecimenDateRollingRate: Double?
    }

    public struct CountryStats: Equatable {
        public let newCasesBySpecimenDateRollingRate: Double?
        public let lastUpdate: GregorianDay
    }

    public enum Direction: Equatable {
        case up, down, same
    }

    public struct LocalAuthorityStats: Equatable {

        public struct Value<T> {
            public let value: T
            public let lastUpdate: GregorianDay
        }

        public let id: LocalAuthorityId
        public let name: String
        public var newCasesByPublishDateRollingSum: Value<Int?>
        public var newCasesByPublishDateChange: Value<Int?>
        public var newCasesByPublishDateDirection: Value<Direction?>
        public var newCasesByPublishDate: Value<Int?>
        public var newCasesByPublishDateChangePercentage: Value<Double?>
        public var newCasesBySpecimenDateRollingRate: Value<Double?>

        public static func == (lhs: LocalCovidStatsDaily.LocalAuthorityStats, rhs: LocalCovidStatsDaily.LocalAuthorityStats) -> Bool {
            lhs.id == rhs.id
        }
    }
}
