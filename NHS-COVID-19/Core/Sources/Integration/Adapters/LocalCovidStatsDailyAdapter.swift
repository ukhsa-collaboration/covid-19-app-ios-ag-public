//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Domain
import Interface

typealias CountryStats = InterfaceLocalCovidStatsDaily.CountryStats
typealias LocalAuthorityStats = InterfaceLocalCovidStatsDaily.LocalAuthorityStats
typealias InterfaceDirection = InterfaceLocalCovidStatsDaily.LocalAuthorityStats.Direction

struct InterfaceLocalCovidStatsDailyError: Error {}

extension InterfaceLocalCovidStatsDaily {
    init(
        domainState: Domain.LocalCovidStatsDaily,
        country: Country,
        localAuthorityId: LocalAuthorityId
    ) throws {
        // Check if local authority is missing in the payload
        guard let lowerTierLocalAuthority = domainState.lowerTierLocalAuthorities[localAuthorityId].map(LocalAuthorityStats.init) else { throw InterfaceLocalCovidStatsDailyError() }
        
        // All of these values are mandatory as stated in the ACs
        let currentCountry = country == .england ? domainState.england : domainState.wales
        if lowerTierLocalAuthority.newCasesByPublishDate.value == nil,
            lowerTierLocalAuthority.newCasesByPublishDateRollingSum.value == nil,
            lowerTierLocalAuthority.newCasesBySpecimenDateRollingRate.value == nil,
            currentCountry.newCasesBySpecimenDateRollingRate == nil {
            throw InterfaceLocalCovidStatsDailyError()
        }
        
        self.init(
            lastFetch: domainState.lastFetch,
            country: CountryStats(
                country: country,
                newCasesBySpecimenDateRollingRate: country == .england ? domainState.england.newCasesBySpecimenDateRollingRate : domainState.wales.newCasesBySpecimenDateRollingRate,
                lastUpdate: currentCountry.lastUpdate
            ),
            lowerTierLocalAuthority: lowerTierLocalAuthority
        )
        
    }
    
}

private extension LocalAuthorityStats {
    init(_ domainState: Domain.LocalCovidStatsDaily.LocalAuthorityStats) {
        
        self.init(
            id: domainState.id.value,
            name: domainState.name,
            newCasesByPublishDateRollingSum: LocalAuthorityStats.Value(domainState.newCasesByPublishDateRollingSum),
            newCasesByPublishDateChange: LocalAuthorityStats.Value(domainState.newCasesByPublishDateChange),
            newCasesByPublishDateDirection: LocalAuthorityStats.Value(direction: domainState.newCasesByPublishDateDirection.value, lastUpdate: domainState.newCasesByPublishDateDirection.lastUpdate),
            newCasesByPublishDate: LocalAuthorityStats.Value(domainState.newCasesByPublishDate),
            newCasesByPublishDateChangePercentage: LocalAuthorityStats.Value(domainState.newCasesByPublishDateChangePercentage),
            newCasesBySpecimenDateRollingRate: LocalAuthorityStats.Value(domainState.newCasesBySpecimenDateRollingRate)
        )
    }
}

private extension LocalAuthorityStats.Value {
    init(_ domainState: Domain.LocalCovidStatsDaily.LocalAuthorityStats.Value<T>) {
        
        self.init(value: domainState.value, lastUpdate: domainState.lastUpdate)
    }
    
    #warning("Think of a better way when saving custom types such as Direction - avoid force unwrapping")
    init(direction: Domain.LocalCovidStatsDaily.Direction?, lastUpdate: GregorianDay) {
        self.init(value: InterfaceDirection(direction) as! T, lastUpdate: lastUpdate)
    }
}

private extension InterfaceDirection {
    
    init?(_ domainState: Domain.LocalCovidStatsDaily.Direction?) {
        switch domainState {
        case .down: self = .down
        case .up: self = .up
        case .same: self = .same
        case .none: return nil
        }
    }
}
