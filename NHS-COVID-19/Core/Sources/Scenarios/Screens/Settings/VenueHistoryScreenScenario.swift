//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation
import Integration
import Interface

public class VenueHistoryScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "Venue history"
    
    public static let didTapEditButton = "Tapped edit button"
    
    public static let venueID1 = "HF912159M5Y"
    public static let venueID2 = "884UGHFJRI"
    public static let venueID3 = "3345GJHOTP"
    public static let checkinDate1 = UTCHour(year: 2020, month: 7, day: 9, hour: 19, minutes: 30).date
    public static let checkinDate2 = UTCHour(year: 2020, month: 7, day: 8, hour: 19, minutes: 30).date
    public static let venueNames: [String] = ["Testing Venue 1 with a very, very long name so that it wraps", "Testing Venue 2", "Testing Venue 3"]
    public static let venuePostcodes: [String?] = ["SW11AA", "SE17EH", nil]
    
    fileprivate static var venueHistories = [
        VenueHistory(
            id: VenueHistory.ID(value: UUID().uuidString),
            venueId: venueID1,
            organisation: venueNames[0],
            postcode: venuePostcodes[0],
            checkedIn: checkinDate1,
            checkedOut: checkinDate1
        ),
        VenueHistory(
            id: VenueHistory.ID(value: UUID().uuidString),
            venueId: venueID2,
            organisation: venueNames[1],
            postcode: venuePostcodes[1],
            checkedIn: checkinDate1,
            checkedOut: checkinDate1
        ),
        VenueHistory(
            id: VenueHistory.ID(value: UUID().uuidString),
            venueId: venueID3,
            organisation: venueNames[2],
            postcode: venuePostcodes[2],
            checkedIn: checkinDate2,
            checkedOut: checkinDate2
        ),
    ]
    
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
