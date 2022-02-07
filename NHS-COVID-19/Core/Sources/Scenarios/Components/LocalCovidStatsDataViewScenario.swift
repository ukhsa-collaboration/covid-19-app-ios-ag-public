//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation
import Integration
import Interface
import SwiftUI

class LocalCovidStatsDataViewScenario: Scenario {
    
    static var appController: AppController {
        BasicAppController(rootViewController: UIHostingController(rootView: LocalCovidStatsDataView(localCovidStats: localCovidStatsDailyOBJ)))
    }
    
    public static let name = "Local Covid Stats Data View"
    public static let kind = ScenarioKind.component
    
}

private var localCovidStatsDailyOBJ: InterfaceLocalCovidStatsDaily {
    
    typealias Value = InterfaceLocalCovidStatsDaily.LocalAuthorityStats.Value
    typealias Direction = InterfaceLocalCovidStatsDaily.LocalAuthorityStats.Direction
    
    let day = GregorianDay(year: 2021, month: 11, day: 18)
    let dayOne = GregorianDay(year: 2021, month: 11, day: 13)
    
    return InterfaceLocalCovidStatsDaily(
        lastFetch: Date(),
        country: InterfaceLocalCovidStatsDaily.CountryStats(
            country: .wales,
            newCasesBySpecimenDateRollingRate: 50,
            lastUpdate: day
        ),
        lowerTierLocalAuthority: InterfaceLocalCovidStatsDaily.LocalAuthorityStats(
            id: "E06000037",
            name: "West Berkshire",
            newCasesByPublishDateRollingSum: Value(value: -771, lastUpdate: day),
            newCasesByPublishDateChange: Value(value: 207, lastUpdate: day),
            newCasesByPublishDateDirection: Value(value: .up, lastUpdate: day),
            newCasesByPublishDate: Value(value: 105, lastUpdate: day),
            newCasesByPublishDateChangePercentage: Value(value: 36.7, lastUpdate: day),
            newCasesBySpecimenDateRollingRate: Value(value: 289.5, lastUpdate: dayOne)
        )
    )
}
