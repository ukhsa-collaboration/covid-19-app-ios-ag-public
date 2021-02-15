//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Integration
import Interface
import SwiftUI
import UIKit

public class MyDataScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "My Data"
    
    public static let postcode = "SW21"
    public static var localAuthority: String? = "Local Authority 1"
    
    public static let didTapEditPostcode = "Tapped edit postcode"
    public static let confirmedDeleteAllData = "Confirmed delete all data"
    
    public static let testResult = Interface.TestResult.positive
    public static let testKitType = Interface.TestKitType.labResult
    public static let confirmationStatus = MyDataViewController.ViewModel.TestResultDetails.ConfirmationStatus.confirmed(onDay: GregorianDay(year: 2021, month: 1, day: 26))
    
    public static let venueID1 = "HF912159M5Y"
    public static let venueID2ToDelete = "FHF84HFY4"
    public static let venueID3 = "884UGHFJRI"
    public static let venueID4 = "3345GJHOTP"
    public static let venueID5 = "AAASDF456TF"
    public static let venueNameShort = "Testing Venue"
    public static let venueNameToDelete = "Testing Venue, to be deleted"
    public static let venueNameLong = "This is a very long name for the Venue to test if the layout makes sense"
    public static let testResultDate = Calendar.utc.date(from: DateComponents(year: 2020, month: 5, day: 6, hour: 8))!
    public static let symptomsDate = Calendar.utc.date(from: DateComponents(year: 2020, month: 5, day: 7, hour: 8))!
    public static let encounterDate = Calendar.utc.date(from: DateComponents(year: 2020, month: 5, day: 8, hour: 8))!
    public static let notificationDate = Calendar.utc.date(from: DateComponents(year: 2020, month: 5, day: 11, hour: 8))!
    public static let endSelfIsolationDate = Calendar.utc.date(from: DateComponents(year: 2020, month: 5, day: 22, hour: 8))!
    
    fileprivate static var venueHistories = [
        VenueHistory(
            id: venueID1,
            organisation: venueNameShort,
            checkedIn: Date(),
            checkedOut: Date(),
            delete: {}
        ),
        VenueHistory(
            id: venueID2ToDelete,
            organisation: venueNameToDelete,
            checkedIn: Date(),
            checkedOut: Date(),
            delete: {}
        ),
        VenueHistory(
            id: venueID3,
            organisation: venueNameShort,
            checkedIn: Date(),
            checkedOut: Date(),
            delete: {}
        ),
        VenueHistory(
            id: venueID4,
            organisation: venueNameLong,
            checkedIn: Date(),
            checkedOut: Date(),
            delete: {}
        ),
        VenueHistory(
            id: venueID5,
            organisation: venueNameLong,
            checkedIn: Date(),
            checkedOut: Date(),
            delete: {}
        ),
    ]
    
    static var appController: AppController {
        NavigationAppController { parent in
            MyDataViewController(
                viewModel: .init(
                    postcode: .constant(postcode),
                    localAuthority: .constant(localAuthority),
                    testResultDetails: .init(
                        result: testResult,
                        date: testResultDate,
                        testKitType: testKitType,
                        confirmationStatus: confirmationStatus
                    ),
                    venueHistories: venueHistories,
                    symptomsOnsetDate: symptomsDate,
                    exposureNotificationDetails: .init(
                        encounterDate: encounterDate,
                        notificationDate: notificationDate
                    ),
                    selfIsolationEndDate: endSelfIsolationDate
                ),
                interactor: Interactor(
                    didTapEditPostcode: { parent.showAlert(title: didTapEditPostcode) },
                    updateVenueHistories: { deletedVenueHistory in
                        venueHistories = venueHistories.filter { $0 != deletedVenueHistory }
                        return venueHistories
                    },
                    deleteAppData: { parent.showAlert(title: confirmedDeleteAllData) }
                )
            )
        }
    }
}

private struct Interactor: MyDataViewController.Interacting {
    var didTapEditPostcode: () -> Void
    var updateVenueHistories: (VenueHistory) -> [VenueHistory]
    var deleteAppData: () -> Void
}
