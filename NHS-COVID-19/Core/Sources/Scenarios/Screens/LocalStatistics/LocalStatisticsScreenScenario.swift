//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Integration
import Interface
import UIKit

public class LocalStatisticsScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Local Statistics"
    
    public static let dashboardLinkButtonTapped = "Dashboard Link Button Tapped"
    public static let lastFetchedDate = UTCHour(year: 2021, month: 11, day: 18, hour: 17, minutes: 14).date
    
    static var appController: AppController {
        NavigationAppController { (parent: UINavigationController) in
            let interactor = Interactor(viewController: parent)
            return LocalStatisticsViewController(interactor: interactor, covidStats: localCovidStatsDaily)
        }
    }
}

private class Interactor: LocalStatisticsViewController.Interacting {
    
    private weak var viewController: UIViewController?
    
    init(viewController: UIViewController) {
        self.viewController = viewController
    }
    
    func didTapdashboardLinkButton() {
        viewController?.showAlert(title: LocalStatisticsScreenScenario.dashboardLinkButtonTapped)
    }
    
}

private var localCovidStatsDaily: InterfaceLocalCovidStatsDaily {
    
    typealias Value = InterfaceLocalCovidStatsDaily.LocalAuthorityStats.Value
    typealias Direction = InterfaceLocalCovidStatsDaily.LocalAuthorityStats.Direction
    
    let day = GregorianDay(year: 2021, month: 11, day: 18)
    let dayOne = GregorianDay(year: 2021, month: 11, day: 13)
    
    return InterfaceLocalCovidStatsDaily(
        lastFetch: LocalStatisticsScreenScenario.lastFetchedDate,
        country: InterfaceLocalCovidStatsDaily.CountryStats(
            country: .england,
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
