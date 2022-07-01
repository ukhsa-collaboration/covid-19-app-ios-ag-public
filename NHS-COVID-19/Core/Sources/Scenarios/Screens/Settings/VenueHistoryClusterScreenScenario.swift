//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation
import Integration
import Interface

public class VenueHistoryClusterScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Venue history - many check-ins"

    public static let didTapEditButton = "Tapped edit button"

    fileprivate static var venueHistories: [VenueHistory] = {
        let date1 = UTCHour(year: 2020, month: 7, day: 9, hour: 19, minutes: 30).date
        let date2 = date1.addingTimeInterval(60 * 60 * 24 * 30)
        return Array(1 ..< 30).map {
            let date = Date.randomBetween(start: date1, end: date2)
            return VenueHistory(
                id: VenueHistory.ID(value: UUID().uuidString),
                venueId: String.randomVenueID(),
                organisation: "Venue \($0)",
                postcode: String.randomPostcodeOrNil(),
                checkedIn: date,
                checkedOut: date.addingTimeInterval(600)
            )
        }
    }()

    static var appController: AppController {
        NavigationAppController { parent in
            VenueHistoryViewController(
                viewModel: VenueHistoryViewController.ViewModel(venueHistories: venueHistories),
                interactor: Interactor(
                    updateVenueHistories: { deletedVenueHistory in
                        venueHistories = venueHistories.filter { $0 != deletedVenueHistory }
                        return venueHistories
                    }
                )
            )
        }
    }
}

private struct Interactor: VenueHistoryViewController.Interacting {
    var updateVenueHistories: (VenueHistory) -> [VenueHistory]
}

extension Date {
    fileprivate static func randomBetween(start: Date, end: Date) -> Date {
        var date1 = start
        var date2 = end
        if date2 < date1 {
            let temp = date1
            date1 = date2
            date2 = temp
        }
        let span = TimeInterval.random(in: date1.timeIntervalSinceNow ... date2.timeIntervalSinceNow)
        return Date(timeIntervalSinceNow: span)
    }
}
