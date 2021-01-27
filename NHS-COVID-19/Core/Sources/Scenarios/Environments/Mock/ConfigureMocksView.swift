//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation
import SwiftUI

struct ConfigureMocksView: View {
    
    @ObservedObject
    var dataProvider: MockDataProvider
    
    var body: some View {
        NavigationView {
            List {
                Section(header: Text(verbatim: "Postcode Risk")) {
                    TextFieldRow(label: "Red Risk", text: $dataProvider.redPostcodes)
                    TextFieldRow(label: "Amber Risk", text: $dataProvider.amberPostcodes)
                    TextFieldRow(label: "Yellow Risk", text: $dataProvider.yellowPostcodes)
                    TextFieldRow(label: "Green Risk", text: $dataProvider.greenPostcodes)
                    TextFieldRow(label: "Neutral Risk", text: $dataProvider.neutralPostcodes)
                }
                Section(header: Text(verbatim: "Local Authorities Risk")) {
                    TextFieldRow(label: "Red Risk", text: $dataProvider.redLocalAuthorities)
                    TextFieldRow(label: "Amber Risk", text: $dataProvider.amberLocalAuthorities)
                    TextFieldRow(label: "Yellow Risk", text: $dataProvider.yellowLocalAuthorities)
                    TextFieldRow(label: "Green Risk", text: $dataProvider.greenLocalAuthorities)
                    TextFieldRow(label: "Neutral Risk", text: $dataProvider.neutralLocalAuthorities)
                }
                Section(header: Text(verbatim: "Check In")) {
                    TextFieldRow(label: "High Risk Venue IDs", text: $dataProvider.riskyVenueIDs)
                }
                Section(header: Text(verbatim: "Virology testing")) {
                    Picker(selection: $dataProvider.testKitType, label: Text("Test kit type")) {
                        ForEach(0 ..< MockDataProvider.testKitType.count) {
                            Text(verbatim: MockDataProvider.testKitType[$0])
                        }
                    }
                    Toggle("Key submission supported", isOn: $dataProvider.keySubmissionSupported)
                    TextFieldRow(label: "Website", text: $dataProvider.orderTestWebsite)
                    TextFieldRow(label: "Reference Code", text: $dataProvider.testReferenceCode)
                    TextFieldRow(label: "Days since test result end date", text: $dataProvider.testResultEndDateDaysAgoString)
                    Picker(selection: $dataProvider.receivedTestResult, label: Text("Result")) {
                        ForEach(0 ..< MockDataProvider.testResults.count) {
                            Text(verbatim: MockDataProvider.testResults[$0])
                        }
                    }
                }
                Section(header: Text(verbatim: "App Availability")) {
                    TextFieldRow(label: "Minimum OS version", text: $dataProvider.minimumOSVersion)
                    TextFieldRow(label: "Minimum app version", text: $dataProvider.minimumAppVersion)
                    TextFieldRow(label: "Recommended app version", text: $dataProvider.recommendedAppVersion)
                    TextFieldRow(label: "Recommended OS version", text: $dataProvider.recommendedOSVersion)
                    TextFieldRow(label: "Latest app version", text: $dataProvider.latestAppVersion)
                }
                Section(header: Text(verbatim: "Exposure Notification")) {
                    VStack(alignment: .leading) {
                        Toggle("Use fake EN contacts", isOn: $dataProvider.useFakeENContacts)
                        Text(verbatim: "Only takes effect after restarting the scenario")
                            .font(.caption)
                    }
                    TextFieldRow(label: "Count of EN contacts", text: $dataProvider.numberOfContactsString)
                    TextFieldRow(label: "Days since EN contacts", text: $dataProvider.contactDaysAgoString)
                }
                Section(header: Text(verbatim: "Hello tester! 👋🏼"), footer: Text(verbatim: "Happy testing 🙌🏼")) {
                    Text(verbatim: """
                    Your friend, the developer here. Hope you’re having a good day.
                    
                    Let us know if you need any more help with testing and we’ll do our best to support you.
                    """)
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Mocks")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
}

private struct TextFieldRow: View {
    
    var label: String
    var text: Binding<String>
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(verbatim: label)
                .font(.caption)
            TextField("", text: text)
        }
    }
    
}
