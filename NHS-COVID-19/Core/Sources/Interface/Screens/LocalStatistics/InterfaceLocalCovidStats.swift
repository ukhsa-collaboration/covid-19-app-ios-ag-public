//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation

public struct InterfaceLocalCovidStatsDaily: Equatable {
    
    public let lastFetch: Date
    public let country: CountryStats
    public let lowerTierLocalAuthority: LocalAuthorityStats
    
    public init(
        lastFetch: Date,
        country: CountryStats,
        lowerTierLocalAuthority: LocalAuthorityStats
    ) {
        self.lastFetch = lastFetch
        self.country = country
        self.lowerTierLocalAuthority = lowerTierLocalAuthority
    }
}

extension InterfaceLocalCovidStatsDaily {
    
    public struct CountryStats: Equatable {
        public let country: Country
        public let newCasesBySpecimenDateRollingRate: Double?
        public let lastUpdate: GregorianDay
        
        public init(
            country: Country,
            newCasesBySpecimenDateRollingRate: Double?,
            lastUpdate: GregorianDay
            
        ) {
            self.country = country
            self.newCasesBySpecimenDateRollingRate = newCasesBySpecimenDateRollingRate
            self.lastUpdate = lastUpdate
        }
        
    }
}

extension InterfaceLocalCovidStatsDaily {
    public struct LocalAuthorityStats: Equatable {
        
        public enum Direction: Equatable {
            case up, down, same
        }
        
        public struct Value<T: Equatable>: Equatable {
            public let value: T
            public let lastUpdate: GregorianDay
            
            public init(value: T, lastUpdate: GregorianDay) {
                self.value = value
                self.lastUpdate = lastUpdate
            }
        }
        
        public let id: String
        public let name: String
        public var newCasesByPublishDateRollingSum: Value<Int?>
        public var newCasesByPublishDateChange: Value<Int?>
        public var newCasesByPublishDateDirection: Value<Direction?>
        public var newCasesByPublishDate: Value<Int?>
        public var newCasesByPublishDateChangePercentage: Value<Double?>
        public var newCasesBySpecimenDateRollingRate: Value<Double?>
        
        public init(
            id: String,
            name: String,
            newCasesByPublishDateRollingSum: LocalAuthorityStats.Value<Int?>,
            newCasesByPublishDateChange: LocalAuthorityStats.Value<Int?>,
            newCasesByPublishDateDirection: LocalAuthorityStats.Value<LocalAuthorityStats.Direction?>,
            newCasesByPublishDate: LocalAuthorityStats.Value<Int?>,
            newCasesByPublishDateChangePercentage: LocalAuthorityStats.Value<Double?>,
            newCasesBySpecimenDateRollingRate: LocalAuthorityStats.Value<Double?>
        ) {
            self.id = id
            self.name = name
            self.newCasesByPublishDateRollingSum = newCasesByPublishDateRollingSum
            self.newCasesByPublishDateChange = newCasesByPublishDateChange
            self.newCasesByPublishDateDirection = newCasesByPublishDateDirection
            self.newCasesByPublishDate = newCasesByPublishDate
            self.newCasesByPublishDateChangePercentage = newCasesByPublishDateChangePercentage
            self.newCasesBySpecimenDateRollingRate = newCasesBySpecimenDateRollingRate
        }
    }
}
