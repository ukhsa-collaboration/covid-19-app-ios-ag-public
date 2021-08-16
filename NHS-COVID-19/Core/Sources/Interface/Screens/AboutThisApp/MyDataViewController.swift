//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Localization
import UIKit

private extension TestResult {
    var description: String {
        switch self {
        case .positive:
            return localize(.mydata_test_result_positive)
        case .negative:
            return localize(.mydata_test_result_negative)
        case .void:
            return localize(.mydata_test_result_void)
        }
    }
}

private extension TestKitType {
    var description: String {
        switch self {
        case .labResult:
            return localize(.mydata_test_result_lab_result)
        case .rapidResult:
            return localize(.mydata_test_result_rapid_result)
        case .rapidSelfReported:
            return localize(.mydata_test_result_rapid_self_reported)
        }
    }
}

public class MyDataViewController: UITableViewController {
    public class ViewModel {
        var testResultDetails: TestResultDetails?
        var symptomsOnsetDate: Date?
        var exposureNotificationDetails: ExposureNotificationDetails?
        var selfIsolationEndDate: Date?
        var venueOfRiskDate: Date?
        
        public struct ExposureNotificationDetails {
            let encounterDate: Date
            let notificationDate: Date
            let optOutOfIsolationDate: Date?
            
            public init(encounterDate: Date,
                        notificationDate: Date,
                        optOutOfIsolationDate: Date?) {
                self.encounterDate = encounterDate
                self.notificationDate = notificationDate
                self.optOutOfIsolationDate = optOutOfIsolationDate
            }
        }
        
        public struct TestResultDetails {
            let result: TestResult
            let acknowledgementDate: Date?
            let testEndDate: Date?
            let testKitType: TestKitType?
            
            public enum CompletionStatus: CustomStringConvertible {
                case pending
                case completed(onDay: GregorianDay)
                case notRequired
                
                public var description: String {
                    switch self {
                    case .pending:
                        return localize(.mydata_test_result_follow_up_pending)
                    case .completed:
                        return localize(.mydata_test_result_follow_up_complete)
                    case .notRequired:
                        return localize(.mydata_test_result_follow_up_not_required)
                    }
                }
                
                public var subtitle: String? {
                    if case .completed(let completedOnDay) = self {
                        return localize(.mydata_date_description(date: completedOnDay.startDate(in: .current)))
                    }
                    return nil
                }
            }
            
            let completionStatus: CompletionStatus?
            
            public init(result: TestResult, acknowledgementDate: Date, testEndDate: Date?, testKitType: TestKitType?, completionStatus: CompletionStatus?) {
                self.result = result
                self.acknowledgementDate = acknowledgementDate
                self.testEndDate = testEndDate
                self.testKitType = testKitType
                self.completionStatus = completionStatus
            }
        }
        
        public init(
            testResultDetails: TestResultDetails?,
            symptomsOnsetDate: Date?,
            exposureNotificationDetails: ExposureNotificationDetails?,
            selfIsolationEndDate: Date?,
            venueOfRiskDate: Date?
        ) {
            self.testResultDetails = testResultDetails
            self.symptomsOnsetDate = symptomsOnsetDate
            self.exposureNotificationDetails = exposureNotificationDetails
            self.selfIsolationEndDate = selfIsolationEndDate
            self.venueOfRiskDate = venueOfRiskDate
        }
    }
    
    private let viewModel: ViewModel
    
    enum HeaderType {
        case basic(title: String)
    }
    
    enum RowType {
        case testAcknowledgementDate(Date)
        case testEndDate(Date)
        case testResult(TestResult)
        case testKitType(TestKitType)
        case completionDate(String)
        case completionStatus(ViewModel.TestResultDetails.CompletionStatus)
        case symptomsOnsetDate(Date)
        case encounterDate(Date)
        case notificationDate(Date)
        case lastDayOfSelfIsolation(Date)
        case venueOfRiskDate(Date)
        case optOutOfContactIsolation(Date)
    }
    
    private struct Section {
        var header: HeaderType
        var rows: [RowType]
    }
    
    private var content: [Section] {
        let testResultSection: Section? = viewModel.testResultDetails.map {
            Section(
                header: .basic(title: localize(.mydata_section_test_result_description)),
                rows: [
                    $0.testEndDate.map { testEndDate in
                        .testEndDate(testEndDate)
                    },
                    $0.acknowledgementDate.map { acknowledgementDate in
                        .testAcknowledgementDate(acknowledgementDate)
                    },
                    .testResult($0.result),
                    $0.testKitType.map { kitType in
                        .testKitType(kitType)
                    },
                    $0.completionStatus?.subtitle.map {
                        .completionDate($0)
                    },
                    .completionStatus($0.completionStatus ?? .notRequired),
                ].compactMap { $0 }
            )
        }
        
        let symptomsOnsetSection: Section? = viewModel.symptomsOnsetDate.map {
            Section(
                header: .basic(title: localize(.mydata_section_symptoms_heading)),
                rows: [.symptomsOnsetDate($0)]
            )
        }
        
        let exposureNotificationSection: Section? = viewModel.exposureNotificationDetails.map {
            Section(
                header: .basic(title: localize(.mydata_section_exposure_notification_description)),
                rows: [
                    .encounterDate($0.encounterDate),
                    .notificationDate($0.notificationDate),
                    $0.optOutOfIsolationDate.map {
                        .optOutOfContactIsolation($0)
                    },
                ].compactMap { $0 }
            )
        }
        
        let lastDayOfSelfIsolationSection: Section? = viewModel.selfIsolationEndDate.map {
            Section(
                header: .basic(title: localize(.mydata_section_self_isolation_heading)),
                rows: [
                    .lastDayOfSelfIsolation($0),
                ]
            )
        }
        
        let venueOfRiskDateSection: Section? = viewModel.venueOfRiskDate.map {
            Section(
                header: .basic(title: localize(.mydata_section_venue_of_risk_heading)),
                rows: [
                    .venueOfRiskDate($0),
                ]
            )
        }
        
        return [testResultSection, lastDayOfSelfIsolationSection, symptomsOnsetSection, venueOfRiskDateSection, exposureNotificationSection].compactMap { $0 }
    }
    
    public init(viewModel: ViewModel) {
        self.viewModel = viewModel
        super.init(style: .grouped)
        tableView.allowsSelection = false
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        tableView.reloadData()
    }
    
    override public func numberOfSections(in tableView: UITableView) -> Int {
        content.count
    }
    
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        content[section].rows.count
    }
    
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell: UITableViewCell
        switch content[indexPath.section].rows[indexPath.row] {
        case .testAcknowledgementDate(let date):
            cell = TextCell.create(tableView: tableView, title: localize(.mydata_test_result_test_acknowledgement_date), date: date)
        case .testEndDate(let date):
            cell = TextCell.create(tableView: tableView, title: localize(.mydata_test_result_test_end_date), date: date)
        case .testResult(let result):
            cell = TextCell.create(tableView: tableView, title: localize(.mydata_test_result_test_result), value: result.description)
        case .testKitType(let testKitType):
            cell = TextCell.create(tableView: tableView, title: localize(.mydata_test_result_test_kit_type), value: testKitType.description)
        case .completionDate(let date):
            cell = TextCell.create(tableView: tableView, title: localize(.mydata_test_result_follow_up_test_date), value: date)
        case .completionStatus(let completionStatus):
            cell = TextCell.create(tableView: tableView, title: localize(.mydata_test_result_follow_up_test_status), value: completionStatus.description)
        case .symptomsOnsetDate(let date):
            cell = TextCell.create(tableView: tableView, title: localize(.mydata_section_symptoms_date), date: date)
        case .lastDayOfSelfIsolation(let date):
            #warning("Find a safer day of doing this")
            // We should show the last day of isolation, not the first day after isolation, hence the going backward.
            // From a date calculation point of view this is correct, however this is somewhat error prone, so would be
            // better to resolve this in a different way.
            //
            // One possible solution is to send a `GregorianDay` to this field instead of a `Date` so we can specify
            // the actual "day isolation ends" instead of "moment isolation ends".
            let justBeforeEndOfIsolation = date.advanced(by: -1)
            cell = TextCell.create(tableView: tableView, title: localize(.mydata_section_self_isolation_end_date), date: justBeforeEndOfIsolation)
        case .venueOfRiskDate(let date):
            cell = TextCell.create(tableView: tableView, title: localize(.mydata_section_venue_of_risk_date), date: date)
        case .encounterDate(let date):
            cell = TextCell.create(tableView: tableView, title: localize(.mydata_exposure_notification_details_exposure_date_description), date: date)
        case .notificationDate(let date):
            cell = TextCell.create(tableView: tableView, title: localize(.mydata_exposure_notification_details_notification_date_description), date: date)
        case .optOutOfContactIsolation(let date):
            cell = TextCell.create(tableView: tableView, title: localize(.mydata_exposure_notification_details_opt_out_date_description), date: date)
        }
        
        // Trigger a layout pass to prevent incorrect cell content layout
        cell.setNeedsDisplay()
        cell.layoutIfNeeded()
        return cell
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        title = localize(.mydata_screen_title)
        view.styleAsScreenBackground(with: traitCollection)
        
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.sectionFooterHeight = .zero
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionFooterHeight = UITableView.automaticDimension
        
        tableView.register(SectionHeader.self, forHeaderFooterViewReuseIdentifier: SectionHeader.reuseIdentifier)
        tableView.register(TextCell.self, forCellReuseIdentifier: TextCell.reuseIdentifier)
        
        if content.count == 0 {
            tableView.backgroundView = EmptySettingsView(
                image: UIImage(.settingInfo),
                description: localize(.settings_no_records)
            )
        }
    }
    
    override public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch content[section].header {
        case .basic(let title):
            return SectionHeader.create(tableView: tableView, title: title)
        }
    }
}
