//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation
import Localization
import SwiftUI

public enum TestResult: CustomStringConvertible {
    case positive
    case negative
    
    public var description: String {
        switch self {
        case .positive:
            return localize(.mydata_test_result_positive)
        case .negative:
            return localize(.mydata_test_result_negative)
        }
    }
}

public struct VenueHistory: Hashable, Equatable {
    let id: String
    let organisation: String
    let checkedIn: Date
    let checkedOut: Date
    public init(id: String, organisation: String, checkedIn: Date, checkedOut: Date) {
        self.id = id
        self.organisation = organisation
        self.checkedIn = checkedIn
        self.checkedOut = checkedOut
    }
}

public struct AppData {
    var postcode: String?
    var testResult: (TestResult, Date)?
    var venueHistory: [VenueHistory]
    var symptomsOnsetDate: Date?
    var encounterDate: Date?
    
    public init(
        postcode: String?,
        testResult: (TestResult, Date)?,
        venueHistory: [VenueHistory],
        symptomsOnsetDate: Date?,
        encounterDate: Date?
    ) {
        self.postcode = postcode
        self.testResult = testResult
        self.venueHistory = venueHistory
        self.symptomsOnsetDate = symptomsOnsetDate
        self.encounterDate = encounterDate
    }
}

public protocol MyDataViewControllerInteracting {
    func deleteAppData()
}

public struct MyDataView: View {
    
    public typealias Interacting = MyDataViewControllerInteracting
    
    private var data: AppData
    
    private var interactor: Interacting
    
    @State private var showingAlert = false
    
    public init(interactor: Interacting, data: AppData) {
        self.data = data
        self.interactor = interactor
    }
    
    public var body: some View {
        GeometryReader { geometry in
            ScrollView {
                VStack(spacing: .standardSpacing) {
                    if self.data.postcode != nil {
                        self.makePostcodeSection(self.data.postcode!)
                    }
                    
                    if self.data.testResult != nil {
                        self.makeTestResultSection(self.data.testResult!)
                    }
                    
                    if self.data.symptomsOnsetDate != nil {
                        self.makeSymptomsSection(self.data.symptomsOnsetDate!)
                    }
                    
                    if self.data.encounterDate != nil {
                        self.makeEncounterSection(self.data.encounterDate!)
                    }
                    
                    if self.data.venueHistory.count > 0 {
                        self.makeVenueHistorySection(self.data.venueHistory)
                    }
                    
                    Button(action: {
                        self.showingAlert = true
                    }) {
                        Text(localize(.mydata_data_deletion_button_title))
                            .foregroundColor(Color(.errorRed))
                            .listRowBackground(Color.clear)
                            .background(Color.clear)
                    }
                    .background(Color.clear)
                    .alert(isPresented: self.$showingAlert) {
                        Alert(
                            title: Text(localize(.mydata_delete_data_alert_title)),
                            message: Text(localize(.mydata_delete_data_alert_description)),
                            primaryButton: .default(Text(localize(.mydata_delete_data_alert_button_title))) {
                                self.interactor.deleteAppData()
                            },
                            secondaryButton: .cancel()
                        )
                    }
                    .frame(minWidth: 0, maxWidth: .infinity)
                    .padding(.vertical)
                }.frame(width: geometry.size.width)
            }
        }
        .background(Color(.background))
        .navigationBarTitle(Text(localize(.mydata_title)), displayMode: .inline)
    }
    
    private func makePostcodeSection(_ postcode: String) -> some View {
        SectionHeader(
            header: Text(localize(.mydata_section_postcode_description))
        ) {
            TextRow(text: postcode)
        }
    }
    
    private func makeTestResultSection(_ testResult: (result: TestResult, date: Date)) -> some View {
        SectionHeader(
            header: Text(localize(.mydata_section_test_result_description))
        ) {
            TextDateRow(text: testResult.result.description, date: testResult.date)
        }
    }
    
    private func makeVenueHistorySection(_ venueHistories: [VenueHistory]) -> some View {
        SectionHeader(
            header: Text(localize(.mydata_section_venue_history_description))
        ) {
            ForEach(venueHistories, id: \.self) { venueHistory in
                VStack(spacing: 0) {
                    VenueHistoryRow(venueHistory: venueHistory, shouldShowDivider: venueHistory != venueHistories.last)
                }
            }
        }
    }
    
    private func makeSymptomsSection(_ date: Date) -> some View {
        SectionHeader(
            header: Text(localize(.mydata_section_symptoms_description))
        ) {
            DateRow(date: date)
        }
    }
    
    private func makeEncounterSection(_ date: Date) -> some View {
        SectionHeader(
            header: Text(localize(.mydata_section_encounter_description))
        ) {
            DateRow(date: date)
        }
    }
}

private struct SectionHeader<Header: View, Content: View>: View {
    
    var header: Header
    var content: () -> Content
    
    init(header: Header, @ViewBuilder content: @escaping () -> Content) {
        self.header = header
        self.content = content
    }
    
    var body: some View {
        VStack(spacing: 0) {
            header
                .font(.body)
                .foregroundColor(Color(.sectionHeaderText))
                .padding()
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            content()
                .font(.body)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            
        }
        .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
    }
}

private struct TextRow: View {
    var text: String
    var body: some View {
        Text(text)
            .padding()
            .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            .background(Color(.surface))
    }
}

private struct DateRow: View {
    var date: Date
    var body: some View {
        HStack {
            Text(localize(.mydata_section_date_description))
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            Text(localize(.mydata_date_description(date: date)))
                .foregroundColor(Color(.secondaryText))
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
        }
        .padding()
        .frame(minWidth: 0, maxWidth: .infinity)
        .background(Color(.surface))
    }
}

private struct TextDateRow: View {
    var text: String
    var date: Date
    var body: some View {
        HStack {
            Text(text)
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
            Text(localize(.mydata_date_description(date: date)))
                .foregroundColor(Color(.secondaryText))
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
        }
        .padding()
        .frame(minWidth: 0, maxWidth: .infinity)
        .background(Color(.surface))
    }
}

private struct VenueHistoryRow: View {
    var venueHistory: VenueHistory
    var shouldShowDivider: Bool = true
    var body: some View {
        VStack(spacing: 0) {
            HStack(alignment: .top) {
                VStack {
                    Text(venueHistory.organisation)
                        .foregroundColor(Color(.primaryText))
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                
                VStack {
                    Text(venueHistory.id)
                        .foregroundColor(Color(.secondaryText))
                }
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .trailing)
            }
            .padding(.vertical)
            
            Text(localize(.mydata_date_interval_description(startdate: venueHistory.checkedIn, endDate: venueHistory.checkedOut)))
                .foregroundColor(Color(.primaryText))
                .frame(minWidth: 0, maxWidth: .infinity, alignment: .leading)
                .padding(.bottom)
            
            if shouldShowDivider {
                Divider()
                    .background(Color(.separator))
            }
        }
        .padding(.horizontal)
        .frame(minWidth: 0, maxWidth: .infinity)
        .background(Color(.surface))
    }
}
