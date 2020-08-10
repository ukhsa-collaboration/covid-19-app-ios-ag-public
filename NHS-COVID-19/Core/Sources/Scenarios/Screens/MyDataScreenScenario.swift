//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import Interface
import SwiftUI
import UIKit

public class MyDataScreenScenario: Scenario {
    public static var kind = ScenarioKind.screen
    public static var name: String = "My Data"
    
    public static let postcode = "SW21"
    public static let venueID1 = "HF912159M5Y"
    public static let venueID2 = "FHF84HFY4"
    public static let venueID3 = "884UGHFJRI"
    public static let venueID4 = "3345GJHOTP"
    public static let venueID5 = "AAASDF456TF"
    public static let venueNameShort = "Testing Venue"
    public static let venueNameLong = "This is a very long name for the Venue to test if the layout makes sense"
    public static let testResult: TestResult = .negative
    public static let testResultDate = Calendar.utc.date(from: DateComponents(year: 2020, month: 5, day: 6, hour: 8))!
    public static let symptomsDate = Calendar.utc.date(from: DateComponents(year: 2020, month: 5, day: 7, hour: 8))!
    public static let encounterDate = Calendar.utc.date(from: DateComponents(year: 2020, month: 5, day: 8, hour: 8))!
    
    fileprivate static let myData = AppData(
        postcode: postcode,
        testResult: (TestResult.negative, testResultDate),
        venueHistory: [
            VenueHistory(id: venueID1, organisation: venueNameShort, checkedIn: Date(), checkedOut: Date()),
            VenueHistory(id: venueID2, organisation: venueNameShort, checkedIn: Date(), checkedOut: Date()),
            VenueHistory(id: venueID3, organisation: venueNameShort, checkedIn: Date(), checkedOut: Date()),
            VenueHistory(id: venueID4, organisation: venueNameLong, checkedIn: Date(), checkedOut: Date()),
            VenueHistory(id: venueID5, organisation: venueNameLong, checkedIn: Date(), checkedOut: Date()),
        ],
        symptomsOnsetDate: symptomsDate,
        encounterDate: encounterDate
    )
    
    static var appController: AppController {
        let viewController = UIHostingController(rootView: ScenarioContainerView())
        return BasicAppController(rootViewController: viewController)
    }
}

private struct ScenarioContainerView: View {
    @State var preferredColourScheme: ColorScheme? = nil
    
    @SwiftUI.Environment(\.colorScheme) var colorScheme
    
    fileprivate init() {}
    
    var body: some View {
        NavigationView {
            MyDataView(interactor: MyDataInterator(), data: MyDataScreenScenario.myData)
                .navigationBarItems(trailing: toggleColorSchemeButton)
        }
        .preferredColorScheme(preferredColourScheme)
        
    }
    
    private var toggleColorSchemeButton: some View {
        Button(action: self.toggleColorScheme) {
            Image(systemName: colorScheme == .dark ? "moon.circle.fill" : "moon.circle")
                .frame(width: 44, height: 44)
        }
    }
    
    private func toggleColorScheme() {
        switch colorScheme {
        case .dark:
            preferredColourScheme = .light
        default:
            preferredColourScheme = .dark
        }
    }
    
    private class MyDataInterator: MyDataView.Interacting {
        func deleteAppData() {}
    }
}
