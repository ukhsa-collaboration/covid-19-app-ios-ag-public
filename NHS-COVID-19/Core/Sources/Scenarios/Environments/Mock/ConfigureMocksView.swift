//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation
import Localization
import Lokalise
import SwiftUI

class LokaliseState: ObservableObject {
    
    @ObservedObject
    var dataProvider: MockDataProvider
    
    struct StringsUpdateError: Identifiable {
        let error: Error
        let id = UUID()
    }
    
    @Published
    var showStringsUpdateError: StringsUpdateError? = nil
    
    struct StringsUpdateResult: Identifiable {
        let result: Bool
        let id = UUID()
    }
    
    @Published
    var showStringsUpdateResult: StringsUpdateResult?
    
    @Published
    var showStringsUpdatingSpinner = false
    
    var showDownloadedStrings: Binding<Bool> {
        Binding {
            self.dataProvider.lokaliseShowDownloadedStrings
        } set: { newValue in
            self.dataProvider.lokaliseShowDownloadedStrings = newValue
        }
    }
    
    init(dataProvider: MockDataProvider) {
        self.dataProvider = dataProvider
    }
    
    func checkForUpdates(_ completion: @escaping (Bool, Error?) -> Void) {
        showStringsUpdatingSpinner = true
        Lokalise.shared.checkForUpdates { updated, error in
            self.showStringsUpdatingSpinner = false
            if let error = error {
                self.showStringsUpdateError = StringsUpdateError(error: error)
            } else {
                self.showStringsUpdateResult = updated ? StringsUpdateResult(result: true) : nil
            }
            completion(updated, error)
        }
    }
}

struct ConfigureMocksView: View {
    
    @ObservedObject
    var dataProvider: MockDataProvider
    @ObservedObject
    var lokaliseState: LokaliseState
    
    @Binding
    var showDevView: Bool
    var adjustableDateProvider: AdjustableDateProvider
    
    var body: some View {
        NavigationView {
            List {
                Toggle("Assistive Dev View", isOn: $showDevView)
                Group {
                    Section(header: Text(verbatim: "Date manipulation")) {
                        TextFieldRow(
                            label: """
                            Number of days from now (negative values allowed)
                            It just adds/subtracts 24 hours from the current date
                            """,
                            text: $dataProvider.numberOfDaysFromNowString
                        )
                        DateTextRow(date: adjustableDateProvider.currentDate)
                    }
                    Section(header: Text(verbatim: "Variants of Concern / Local Messages")) {
                        TextFieldRow(label: "Local Authority IDs (comma separated)", text: $dataProvider.vocLocalAuthorities)
                        TextFieldRow(label: "Message ID", text: $dataProvider.vocMessageId)
                        TextFieldRow(label: "Content Version", text: $dataProvider.vocContentVersionString)
                        TextFieldRow(label: "Notification Title", text: $dataProvider.vocMessageNotificationTitle)
                        TextFieldRow(label: "Notification Body", text: $dataProvider.vocMessageNotificationBody)
                    }
                    Section(header: Text(verbatim: "Postcode Risk")) {
                        TextFieldRow(label: "Black Risk", text: $dataProvider.blackPostcodes)
                        TextFieldRow(label: "Maroon Risk", text: $dataProvider.maroonPostcodes)
                        TextFieldRow(label: "Red Risk", text: $dataProvider.redPostcodes)
                        TextFieldRow(label: "Amber Risk", text: $dataProvider.amberPostcodes)
                        TextFieldRow(label: "Yellow Risk", text: $dataProvider.yellowPostcodes)
                        TextFieldRow(label: "Green Risk", text: $dataProvider.greenPostcodes)
                        TextFieldRow(label: "Neutral Risk", text: $dataProvider.neutralPostcodes)
                    }
                    Section(header: Text(verbatim: "Local Authorities Risk")) {
                        TextFieldRow(label: "Black Risk", text: $dataProvider.blackLocalAuthorities)
                        TextFieldRow(label: "Maroon Risk", text: $dataProvider.maroonLocalAuthorities)
                        TextFieldRow(label: "Red Risk", text: $dataProvider.redLocalAuthorities)
                        TextFieldRow(label: "Amber Risk", text: $dataProvider.amberLocalAuthorities)
                        TextFieldRow(label: "Yellow Risk", text: $dataProvider.yellowLocalAuthorities)
                        TextFieldRow(label: "Green Risk", text: $dataProvider.greenLocalAuthorities)
                        TextFieldRow(label: "Neutral Risk", text: $dataProvider.neutralLocalAuthorities)
                        TextFieldRow(label: "Minimum Background Task Update Interval (in sec)", text: $dataProvider.riskyLocalAuthorityMinimumBackgroundTaskUpdateIntervalString)
                    }
                    Section(header: Text(verbatim: "Check In")) {
                        TextFieldRow(label: "Risky Venue IDs (warn and inform)", text: $dataProvider.riskyVenueIDsWarnAndInform)
                        TextFieldRow(label: "Risky Venue IDs (warn and book a test)", text: $dataProvider.riskyVenueIDsWarnAndBookTest)
                        TextFieldRow(label: "Option to book a test (in days)", text: $dataProvider.optionToBookATestString)
                    }
                    Section(header: Text(verbatim: "Virology testing")) {
                        Picker(selection: $dataProvider.testKitType, label: Text("Test kit type")) {
                            ForEach(0 ..< MockDataProvider.testKitType.count) {
                                Text(verbatim: MockDataProvider.testKitType[$0])
                            }
                        }
                        Toggle("Key submission supported", isOn: $dataProvider.keySubmissionSupported)
                        Toggle("Requires confirmatory test", isOn: $dataProvider.requiresConfirmatoryTest)
                        TextFieldRow(label: "Website", text: $dataProvider.orderTestWebsite)
                        TextFieldRow(label: "Reference Code", text: $dataProvider.testReferenceCode)
                        TextFieldRow(label: "Days since test result end date", text: $dataProvider.testResultEndDateDaysAgoString)
                        TextFieldRow(label: "Confirmatory day limit", text: $dataProvider.confirmatoryDayLimitString)
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
                    if Localization.current.overrider != nil {
                        Section(header: Text(verbatim: "Lokalise")) {
                            Button {
                                lokaliseState.checkForUpdates { updated, error in
                                    if error == nil, updated {
                                        dataProvider.lokaliseLastUpdate = Date()
                                    }
                                }
                            } label: {
                                HStack {
                                    Text("Update Strings")
                                    Spacer()
                                    if #available(iOS 14.0, *) {
                                        if lokaliseState.showStringsUpdatingSpinner {
                                            ProgressView()
                                        }
                                    }
                                }
                            }
                            .alert(item: $lokaliseState.showStringsUpdateError) { error in
                                Alert(title: Text("\(error.error.localizedDescription)"))
                            }
                            Text("Test string: \(localize(.this_is_just_a_test_message))")
                                // this is just randomly attached to this Text to prevent it being blocked by the error alert attached to the update button
                                .alert(item: $lokaliseState.showStringsUpdateResult) { _ in
                                    Alert(title: Text("Strings successfully updated"), message: Text("Restart the app to see changes and ensure 'Show downloaded strings' is on"))
                                }
                            if let lokaliseLastUpdate = dataProvider.lokaliseLastUpdate {
                                Text("\(lokaliseLastUpdate)")
                                    .font(.caption)
                            }
                            Toggle("Show downloaded strings", isOn: lokaliseState.showDownloadedStrings)
                            Toggle("Show keys only", isOn: $dataProvider.lokaliseShowKeysOnly)
                        }
                    }
                }
                Group {
                    Section(header: Text(verbatim: "Hello tester! 👋🏼"), footer: Text(verbatim: "Happy testing 🙌🏼")) {
                        Text(verbatim: """
                        Your friend, the developer here. Hope you’re having a good day.
                        
                        Let us know if you need any more help with testing and we’ll do our best to support you.
                        """)
                    }
                }
            }
            .listStyle(GroupedListStyle())
            .navigationBarTitle("Mocks")
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}

struct ConfigureMocksViewPreview: PreviewProvider {
    static var previews: some View {
        let mockDataProvider = MockDataProvider()
        return ConfigureMocksView(
            dataProvider: mockDataProvider,
            lokaliseState: LokaliseState(dataProvider: mockDataProvider),
            showDevView: .constant(false),
            adjustableDateProvider: AdjustableDateProvider()
        )
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

private struct DateTextRow: View {
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateStyle = .long
        return formatter
    }()
    
    let date: Date
    
    var body: some View {
        if #available(iOS 14.0, *) {
            Text(date, style: .date)
        } else {
            Text("\(date, formatter: Self.dateFormatter)")
        }
    }
    
}
