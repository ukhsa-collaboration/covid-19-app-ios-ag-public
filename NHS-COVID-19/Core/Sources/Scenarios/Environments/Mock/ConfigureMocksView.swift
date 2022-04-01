//
// Copyright © 2022 DHSC. All rights reserved.
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
    
    @State private var hasCopiedToClipboard = false
    
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
                        title: "Virology Test Result",
                        systemImage: "heart.text.square",
                        accessoryBadge: {
                            TestResultBadge(
                                testResult: MockDataProvider.testResults[dataProvider.receivedTestResult],
                                testKitType: MockDataProvider.testKitType[dataProvider.testKitType],
                                requiresConfirmatoryTest: dataProvider.requiresConfirmatoryTest,
                                diagnosisKeySubmissionSupported: dataProvider.keySubmissionSupported
                            )
                        }
                    ) {
                        VStack(alignment: .leading) {
                            Text("Use this on the Enter Test Result screen by entering")
                            HStack {
                                Text("testendd")
                                    .overlay(
                                        RoundedRectangle(cornerRadius: .halfHairSpacing).stroke(Color(.nhsLightBlue), lineWidth: 1)
                                    )
                                    .font(.system(.caption, design: .monospaced))
                                Image(systemName: "doc.on.doc")
                                Text(hasCopiedToClipboard ? "Copied to clipboard" : "Tap to copy to clipboard")
                            }
                        }
                        .font(.caption)
                        .onTapGesture {
                            let pasteboard = UIPasteboard.general
                            pasteboard.string = "testendd"
                            hasCopiedToClipboard = true
                        }
                        Picker(selection: $dataProvider.receivedTestResult, label: Text("Result")) {
                            ForEach(0 ..< MockDataProvider.testResults.count) {
                                Text(verbatim: MockDataProvider.testResults[$0])
                            }
                        }
                        Picker(selection: $dataProvider.testKitType, label: Text("Test kit type")) {
                            ForEach(0 ..< MockDataProvider.testKitType.count) {
                                Text(verbatim: MockDataProvider.testKitType[$0])
                            }
                        }
                        StepperNumericInput(
                            value: $dataProvider.testResultEndDateDaysAgo,
                            title: "Days since test result end date",
                            range: 0 ... 60,
                            step: 1
                        )
                        
                        Toggle(isOn: $dataProvider.keySubmissionSupported, label: {
                            VStack(alignment: .leading) {
                                Text("Key submission supported")
                                if dataProvider.keySubmissionSupported {
                                    Text("Will invite you to notify contacts if positive.").font(.caption)
                                } else {
                                    Text("Will NOT invite you to notify contacts.").font(.caption)
                                }
                            }
                        })
                        VStack {
                            Toggle(
                                "Requires confirmatory test",
                                isOn: $dataProvider.requiresConfirmatoryTest
                            )
                            Toggle("Should offer follow-up test", isOn: $dataProvider.shouldOfferFollowUpTest)
                            TextFieldRow(label: "Confirmatory day limit (empty = no limit)", text: $dataProvider.confirmatoryDayLimitString)
                            
                        }
                        if dataProvider.requiresConfirmatoryTest {
                            HStack(alignment: .top) {
                                Image(systemName: "xmark.seal")
                                VStack(alignment: .leading) {
                                    Text("Unconfirmed result")
                                        .fontWeight(.bold)
                                    Text("If positive, can be overruled by a later negative confirmed result \(dataProvider.confirmatoryDayLimit.map { "with a test end date within \($0) day(s)" } ?? "at any time")")
                                    Text("Can not overrule any previous positive results.")
                                }.font(.caption)
                            }
                        } else {
                            HStack(alignment: .top) {
                                Image(systemName: "checkmark.seal.fill")
                                VStack(alignment: .leading) {
                                    Text("Confirmed result")
                                        .fontWeight(.bold)
                                    Text("If positive, can not be overruled by any later result.")
                                    Text("If negative, can overrule a positive unconfirmed result (as long as it is within the unconfirmed test's confirmatory day limit, if it had one.)")
                                }.font(.caption)
                            }
                        }
                        TextFieldRow(label: "Website", text: $dataProvider.orderTestWebsite)
                        TextFieldRow(label: "Reference Code", text: $dataProvider.testReferenceCode)
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
    
    private struct BackwardsCompatibleDisclosureGroup<Content, Badge>: View where Content: View, Badge: View {
        var title: String
        var systemImage: String
        var accessoryBadge: () -> Badge
        var content: () -> Content
        
        init(title: String,
             systemImage: String,
             accessoryText: String,
             accessoryColor: Color,
             @ViewBuilder content: @escaping () -> Content) where Badge == TextAccessoryBadge {
            self.title = title
            self.systemImage = systemImage
            accessoryBadge = {
                TextAccessoryBadge(
                    text: accessoryText,
                    color: accessoryColor
                )
            }
            self.content = content
        }
        
        init(title: String,
             systemImage: String,
             accessoryBadge: @escaping () -> Badge,
             @ViewBuilder content: @escaping () -> Content) {
            self.title = title
            self.systemImage = systemImage
            self.accessoryBadge = accessoryBadge
            self.content = content
        }
        
        init(title: String,
             systemImage: String,
             @ViewBuilder content: @escaping () -> Content) where Badge == EmptyView {
            self.title = title
            self.systemImage = systemImage
            accessoryBadge = { EmptyView() }
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
                            if let accessoryBadge = accessoryBadge {
                                accessoryBadge()
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
                    if let accessoryBadge = accessoryBadge {
                        accessoryBadge()
                    }
                    
                }, content: content)
            }
        }
        
    }
    
    struct TextAccessoryBadge: View {
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

// TODO: Improve this (and the upstream test kit/result types) to make it less reliant on string comparisons.
private struct TestResultBadge: View {
    var testResult: String
    var testKitType: String
    var requiresConfirmatoryTest: Bool
    var diagnosisKeySubmissionSupported: Bool
    
    var body: some View {
        HStack {
            if diagnosisKeySubmissionSupported {
                Image(systemName: "square.and.arrow.up")
            }
            
            if requiresConfirmatoryTest {
                Image(systemName: "xmark.seal")
            } else {
                Image(systemName: "checkmark.seal.fill")
            }
            
            switch testKitType {
            case "LAB_RESULT":
                if #available(iOS 14.0, *) {
                    Image(systemName: "testtube.2")
                } else {
                    Text("LAB")
                        .font(.caption)
                }
            case "RAPID_RESULT":
                Image(systemName: "person.2")
            case "RAPID_SELF_REPORTED":
                Image(systemName: "person")
            default:
                Image(systemName: "questionmark")
            }
            
            switch testResult {
            case "POSITIVE":
                Image(systemName: "plus.circle")
            case "NEGATIVE":
                Image(systemName: "minus.circle")
            case "VOID":
                Image(systemName: "xmark.circle")
            case "PLOD":
                Image(systemName: "plusminus.circle")
            default:
                Image(systemName: "questionmark.circle")
            }
            
        }
        .foregroundColor(preferredColor())
    }
    
    func preferredColor() -> Color {
        switch testResult {
        case "POSITIVE":
            return Color(.errorRed)
        case "NEGATIVE":
            return Color(.nhsBlue)
        case "VOID":
            return Color(.amber)
        default:
            return Color(.primaryText)
        }
    }
}
