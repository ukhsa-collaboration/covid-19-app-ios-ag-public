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
                Toggle(isOn: $showDevView, label: {
                    HStack {
                        Image(systemName: "line.horizontal.3.decrease.circle")
                            .font(.headline)
                            .padding(.halfSpacing / 2)
                        VStack(alignment: .leading) {
                            Text("Assistive Dev View")
                            Text("Keeps a small button on the screen to quickly open this Debug screen. Useful for quick adjustments while testing.").font(.caption)
                        }
                    }
                })
                Group {
                    HStack {
                        Image(systemName: "timer")
                            .font(.headline)
                            .padding(.halfSpacing / 2)
                        DateOffsetRow(
                            offset: $dataProvider.numberOfDaysFromNow,
                            title: "Date Manipulation"
                        )
                    }
                    BackwardsCompatibleDisclosureGroup(
                        title: "Variants/Local Messages",
                        systemImage: "megaphone"
                    ) {
                        TextFieldRow(label: "Local Authority IDs (comma separated)", text: $dataProvider.vocLocalAuthorities)
                        TextFieldRow(label: "Message ID", text: $dataProvider.vocMessageId)
                        StepperNumericInput(value: $dataProvider.vocContentVersion, title: "Content Version", range: 1 ... 1000, step: 1)
                        TextFieldRow(label: "Notification Title", text: $dataProvider.vocMessageNotificationTitle)
                        TextFieldRow(label: "Notification Body", text: $dataProvider.vocMessageNotificationBody)
                    }
                    BackwardsCompatibleDisclosureGroup(
                        title: "Local Authorities Risk",
                        systemImage: "map"
                    ) {
                        TextFieldRow(label: "Black Risk", text: $dataProvider.blackLocalAuthorities)
                        TextFieldRow(label: "Maroon Risk", text: $dataProvider.maroonLocalAuthorities)
                        TextFieldRow(label: "Red Risk", text: $dataProvider.redLocalAuthorities)
                        TextFieldRow(label: "Amber Risk", text: $dataProvider.amberLocalAuthorities)
                        TextFieldRow(label: "Yellow Risk", text: $dataProvider.yellowLocalAuthorities)
                        TextFieldRow(label: "Green Risk", text: $dataProvider.greenLocalAuthorities)
                        TextFieldRow(label: "Neutral Risk", text: $dataProvider.neutralLocalAuthorities)
                        StepperNumericInput(
                            value: $dataProvider.riskyLocalAuthorityMinimumBackgroundTaskUpdateInterval,
                            title: "Minimum Background Task Update Interval (sec)",
                            range: 0 ... 3600,
                            step: 60
                        )
                    }
                    BackwardsCompatibleDisclosureGroup(
                        title: "Risky Venue Alerts",
                        systemImage: "flag"
                    ) {
                        TextFieldRow(label: "Risky Venue IDs (warn and inform)", text: $dataProvider.riskyVenueIDsWarnAndInform)
                        TextFieldRow(label: "Risky Venue IDs (warn and book a test)", text: $dataProvider.riskyVenueIDsWarnAndBookTest)
                        StepperNumericInput(
                            value: $dataProvider.optionToBookATest,
                            title: "Book a test displayed for (days)",
                            range: 0 ... 60,
                            step: 1
                        )
                    }
                    BackwardsCompatibleDisclosureGroup(
                        title: "Virology Test Results",
                        systemImage: "heart.text.square"
                    ) {
                        Picker(selection: $dataProvider.testKitType, label: Text("Test kit type")) {
                            ForEach(0 ..< MockDataProvider.testKitType.count) {
                                Text(verbatim: MockDataProvider.testKitType[$0])
                            }
                        }
                        Toggle("Key submission supported", isOn: $dataProvider.keySubmissionSupported)
                        Toggle("Requires confirmatory test", isOn: $dataProvider.requiresConfirmatoryTest)
                        TextFieldRow(label: "Website", text: $dataProvider.orderTestWebsite)
                        TextFieldRow(label: "Reference Code", text: $dataProvider.testReferenceCode)
                        StepperNumericInput(
                            value: $dataProvider.testResultEndDateDaysAgo,
                            title: "Days since test result end date",
                            range: 0 ... 60,
                            step: 1
                        )
                        TextFieldRow(label: "Confirmatory day limit", text: $dataProvider.confirmatoryDayLimitString)
                        Picker(selection: $dataProvider.receivedTestResult, label: Text("Result")) {
                            ForEach(0 ..< MockDataProvider.testResults.count) {
                                Text(verbatim: MockDataProvider.testResults[$0])
                            }
                        }
                    }
                    BackwardsCompatibleDisclosureGroup(
                        title: "Local Covid Stats",
                        systemImage: "chart.xyaxis.line"
                    ) {
                        TextFieldRow(label: "Local Authority Id", text: $dataProvider.localCovidStatsLAId)
                        Picker(selection: $dataProvider.localCovidStatsDirection, label: Text("Direction")) {
                            ForEach(0 ..< MockDataProvider.covidStatsDirection.count) {
                                Text(verbatim: MockDataProvider.covidStatsDirection[$0])
                            }
                        }
                        Toggle("People tested positive - has data", isOn: $dataProvider.peopleTestedPositiveHasData)
                        Toggle("Cases per 100k - has data", isOn: $dataProvider.casesPer100KHasData)
                    }
                    
                    BackwardsCompatibleDisclosureGroup(
                        title: "App Availability",
                        systemImage: "apps.iphone"
                    ) {
                        TextFieldRow(label: "Minimum OS version", text: $dataProvider.minimumOSVersion, keyboardType: .decimalPad)
                        TextFieldRow(label: "Minimum app version", text: $dataProvider.minimumAppVersion, keyboardType: .decimalPad)
                        TextFieldRow(label: "Recommended app version", text: $dataProvider.recommendedAppVersion, keyboardType: .decimalPad)
                        TextFieldRow(label: "Recommended OS version", text: $dataProvider.recommendedOSVersion, keyboardType: .decimalPad)
                        TextFieldRow(label: "Latest app version", text: $dataProvider.latestAppVersion, keyboardType: .decimalPad)
                    }
                    BackwardsCompatibleDisclosureGroup(
                        title: "Fake Exposure Notifications",
                        systemImage: "person.crop.circle.badge.exclamationmark",
                        accessoryText: dataProvider.useFakeENContacts ? "\(dataProvider.numberOfContacts)" : "OFF",
                        accessoryColor: dataProvider.useFakeENContacts ? Color(.activeScanIndicator) : Color(.gray)
                    ) {
                        VStack(alignment: .leading) {
                            Toggle("Use fake EN contacts", isOn: $dataProvider.useFakeENContacts)
                            Text(verbatim: "Only takes effect after restarting the scenario")
                                .font(.caption)
                        }
                        VStack(alignment: .leading) {
                            Toggle("Bluetooth", isOn: $dataProvider.bluetoothEnabled)
                            Text(verbatim: "Changing this will emit the value instantly")
                                .font(.caption)
                        }
                        StepperNumericInput(
                            value: $dataProvider.numberOfContacts,
                            title: "Number of risky contacts",
                            range: 0 ... 1000,
                            step: 1
                        )
                        StepperNumericInput(
                            value: $dataProvider.contactDaysAgo,
                            title: "Days since encounter",
                            range: 0 ... 60,
                            step: 1
                        )
                    }
                    if Localization.current.overrider != nil {
                        BackwardsCompatibleDisclosureGroup(
                            title: "Lokalise",
                            systemImage: "globe"
                        ) {
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
                    BackwardsCompatibleDisclosureGroup(
                        title: "Fake Venue Check-Ins",
                        systemImage: "building.2.crop.circle",
                        accessoryText: dataProvider.useFakeCheckins ? "ON" : "OFF",
                        accessoryColor: dataProvider.useFakeCheckins ? Color(.activeScanIndicator) : Color(.gray)
                    ) {
                        Toggle("Use fake venues", isOn: $dataProvider.useFakeCheckins)
                        if dataProvider.useFakeCheckins {
                            Group {
                                TextFieldRow(label: "Venue ID", text: $dataProvider.fakeCheckinsVenueID)
                                TextFieldRow(label: "Venue Org", text: $dataProvider.fakeCheckinsVenueOrg)
                                TextFieldRow(label: "Venue Postcode", text: $dataProvider.fakeCheckinsVenuePostcode)
                            }
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
    
    private struct BackwardsCompatibleDisclosureGroup<Content>: View where Content: View {
        var title: String
        var systemImage: String
        var accessoryText: String?
        var accessoryColor: Color?
        var content: () -> Content
        
        init(title: String,
             systemImage: String,
             accessoryText: String? = nil,
             accessoryColor: Color? = nil,
             @ViewBuilder content: @escaping () -> Content) {
            self.title = title
            self.systemImage = systemImage
            self.accessoryText = accessoryText
            self.accessoryColor = accessoryColor
            self.content = content
        }
        
        @State private var isExpanded = false
        
        var body: some View {
            if #available(iOS 14, *) {
                DisclosureGroup(
                    isExpanded: $isExpanded,
                    content: content,
                    label: {
                        HStack {
                            Label(title, systemImage: systemImage)
                            Spacer()
                            if let accessoryText = accessoryText,
                                let accessoryColor = accessoryColor {
                                AccessoryBadge(
                                    text: accessoryText,
                                    color: accessoryColor
                                )
                            }
                        }
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .contentShape(Rectangle())
                        .onTapGesture {
                            withAnimation {
                                isExpanded.toggle()
                            }
                        }
                    }
                )
            } else {
                Section(header: HStack {
                    Text(verbatim: title)
                    Spacer()
                    if let accessoryText = accessoryText,
                        let accessoryColor = accessoryColor {
                        AccessoryBadge(
                            text: accessoryText,
                            color: accessoryColor
                        )
                    }
                    
                }, content: content)
            }
        }
        
        private struct AccessoryBadge: View {
            var text: String
            var color: Color
            
            var body: some View {
                Text(text)
                    .font(.caption)
                    .foregroundColor(Color(.background))
                    .padding(.horizontal, .halfSpacing)
                    .background(color)
                    .cornerRadius(.halfSpacing)
                
            }
        }
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
    var keyboardType: UIKeyboardType
    
    init(label: String,
         text: Binding<String>) {
        self.label = label
        self.text = text
        keyboardType = .default
    }
    
    init(label: String,
         text: Binding<String>,
         keyboardType: UIKeyboardType) {
        self.label = label
        self.text = text
        self.keyboardType = keyboardType
    }
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(verbatim: label)
                .font(.caption)
            TextField(label, text: text)
                .keyboardType(keyboardType)
        }
    }
    
}

private struct StepperNumericInput: View {
    let value: Binding<Int>
    let title: String
    
    let range: ClosedRange<Int>
    let step: Int
    
    var body: some View {
        let string = Binding<String>(
            get: { "\(value.wrappedValue)" },
            set: { newValue in
                if let intNewValue = Int(newValue) {
                    value.wrappedValue = intNewValue
                }
            }
        )
        
        return Stepper(value: value, in: range, step: step) {
            VStack(alignment: .leading) {
                Text(title).font(.caption)
                TextField(
                    title,
                    text: string
                )
                .keyboardType(.numberPad)
            }
        }
    }
}

private struct DateOffsetRow: View {
    
    private static let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.setLocalizedDateFormatFromTemplate("E dd MMM")
        return formatter
    }()
    
    let offset: Binding<Int>
    let title: String
    
    var body: some View {
        let string = Binding<String>(
            get: { "\(offset.wrappedValue)" },
            set: { newValue in
                if let intNewValue = Int(newValue) {
                    offset.wrappedValue = intNewValue
                }
            }
        )
        
        return Stepper(value: offset) {
            VStack(alignment: .leading) {
                Text(title)
                    .font(.caption)
                HStack {
                    TextField(
                        title,
                        text: string
                    )
                    .keyboardType(.numberPad)
                    Spacer()
                    dateText()
                }
            }
        }
    }
    
    private func dateText() -> some View {
        return Text("(\(offsetDate, formatter: Self.dateFormatter))")
            .font(.caption)
    }
    
    var offsetDate: Date {
        Date().addingTimeInterval(TimeInterval(offset.wrappedValue * 60 * 60 * 24))
    }
    
}
