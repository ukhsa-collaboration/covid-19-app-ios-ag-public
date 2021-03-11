//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Localization
import UIKit

public protocol MyDataViewControllerInteracting {
    var didTapEditPostcode: () -> Void { get }
    var updateVenueHistories: (VenueHistory) -> [VenueHistory] { get }
    var deleteAppData: () -> Void { get }
}

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
    public typealias Interacting = MyDataViewControllerInteracting
    
    // Trigger cell height recalculation
    // See https://stackoverflow.com/a/19536877 and https://stackoverflow.com/a/34602615
    private func refreshCellHeight() {
        tableView.beginUpdates()
        tableView.endUpdates()
    }
    
    @Published
    var publishedIsEditing: Bool = false {
        didSet {
            refreshCellHeight()
        }
    }
    
    public class ViewModel {
        @InterfaceProperty
        var postcode: String?
        @InterfaceProperty
        var localAuthority: String?
        var testResultDetails: TestResultDetails?
        var venueHistories: [VenueHistory]
        var symptomsOnsetDate: Date?
        var exposureNotificationDetails: ExposureNotificationDetails?
        var selfIsolationEndDate: Date?
        var dailyTestingOptInDate: Date?
        var venueOfRiskDate: Date?

        public struct ExposureNotificationDetails {
            let encounterDate: Date
            let notificationDate: Date
            
            public init(encounterDate: Date,
                        notificationDate: Date) {
                self.encounterDate = encounterDate
                self.notificationDate = notificationDate
            }
        }
        
        public struct TestResultDetails {
            let result: TestResult
            let date: Date
            let testKitType: TestKitType?
            
            public enum ConfirmationStatus: CustomStringConvertible {
                case pending
                case confirmed(onDay: GregorianDay)
                case notRequired
                public var description: String {
                    switch self {
                    case .pending:
                        return localize(.mydata_test_result_follow_up_pending)
                    case .confirmed:
                        return localize(.mydata_test_result_follow_up_complete)
                    case .notRequired:
                        return localize(.mydata_test_result_follow_up_not_required)
                    }
                }
                
                public var subtitle: String? {
                    if case .confirmed(let confirmedOnDay) = self {
                        return localize(.mydata_date_description(date: confirmedOnDay.startDate(in: .current)))
                    }
                    return nil
                }
            }
            
            let confirmationStatus: ConfirmationStatus?
            
            public init(result: TestResult, date: Date, testKitType: TestKitType?, confirmationStatus: ConfirmationStatus?) {
                self.result = result
                self.date = date
                self.testKitType = testKitType
                self.confirmationStatus = confirmationStatus
            }
        }
        
        public init(
            postcode: InterfaceProperty<String?>,
            localAuthority: InterfaceProperty<String?>,
            testResultDetails: TestResultDetails?,
            venueHistories: [VenueHistory],
            symptomsOnsetDate: Date?,
            exposureNotificationDetails: ExposureNotificationDetails?,
            selfIsolationEndDate: Date?,
            dailyTestingOptInDate: Date?,
            venueOfRiskDate: Date?
        ) {
            _postcode = postcode
            _localAuthority = localAuthority
            self.testResultDetails = testResultDetails
            self.venueHistories = venueHistories
            self.symptomsOnsetDate = symptomsOnsetDate
            self.exposureNotificationDetails = exposureNotificationDetails
            self.selfIsolationEndDate = selfIsolationEndDate
            self.dailyTestingOptInDate = dailyTestingOptInDate
            self.venueOfRiskDate = venueOfRiskDate
        }
    }
    
    private let viewModel: ViewModel
    private let interactor: Interacting
    
    enum HeaderType {
        case venueHistory(title: String, action: () -> Void, isEditing: InterfaceProperty<Bool>)
        case postcode(title: String, action: () -> Void)
        case basic(title: String)
    }
    
    enum RowType {
        case postcode(InterfaceProperty<String?>, InterfaceProperty<String?>)
        case testDate(Date)
        case testResult(TestResult)
        case testKitType(TestKitType)
        case confirmationStatus(ViewModel.TestResultDetails.ConfirmationStatus)
        case venueHistory(VenueHistory)
        case symptomsOnsetDate(Date)
        case encounterDate(Date)
        case notificationDate(Date)
        case lastDayOfSelfIsolation(Date)
        case dailyTestingOptIn(Date)
        case venueOfRiskDate(Date)
    }
    
    private struct Section {
        var header: HeaderType
        var rows: [RowType]
    }
    
    private var content: [Section] {
        let postCodeSection = Section(
            header: .postcode(title: viewModel.localAuthority != nil && viewModel.localAuthority?.isEmpty == false ? localize(.mydata_section_LocalAuthority_description) : localize(.mydata_section_postcode_description), action: interactor.didTapEditPostcode),
            rows: [.postcode(viewModel.$postcode, viewModel.$localAuthority)]
        )
        
        let testResultSection: Section? = viewModel.testResultDetails.map {
            Section(
                header: .basic(title: localize(.mydata_section_test_result_description)),
                rows: [
                    .testDate($0.date),
                    .testResult($0.result),
                    $0.testKitType.map { kitType in
                        .testKitType(kitType)
                    },
                    .confirmationStatus($0.confirmationStatus ?? .notRequired),
                ].compactMap { $0 }
            )
        }
        
        let symptomsOnsetSection: Section? = viewModel.symptomsOnsetDate.map {
            Section(
                header: .basic(title: localize(.mydata_section_symptoms_description)),
                rows: [.symptomsOnsetDate($0)]
            )
        }
        
        let exposureNotificationSection: Section? = viewModel.exposureNotificationDetails.map {
            Section(
                header: .basic(title: localize(.mydata_section_exposure_notification_description)),
                rows: [
                    .encounterDate($0.encounterDate),
                    .notificationDate($0.notificationDate),
                ]
            )
        }
        
        let lastDayOfSelfIsolationSection: Section? = viewModel.selfIsolationEndDate.map {
            Section(
                header: .basic(title: localize(.mydata_section_self_isolation_end_date_description)),
                rows: [
                    .lastDayOfSelfIsolation($0),
                ]
            )
        }
        
        let dailyTestingOptInSection: Section? = viewModel.dailyTestingOptInDate.map {
            Section(
                header: .basic(title: localize(.mydata_section_daily_testing_description)),
                rows: [
                    .dailyTestingOptIn($0),
                ]
            )
        }

        let venueOfRiskDateSection: Section? = viewModel.venueOfRiskDate.map {
            Section(
                header: .basic(title: localize(.mydata_section_venue_of_risk)),
                rows: [
                    .venueOfRiskDate($0),
                ]
            )
        }
        
        let venueHistories = viewModel.venueHistories.isEmpty ? nil : Section(
            header: .venueHistory(
                title: localize(.mydata_section_venue_history_description),
                action: { [weak self] in
                    guard let self = self else { return }
                    self.publishedIsEditing = !self.publishedIsEditing
                },
                isEditing: $publishedIsEditing.property(initialValue: publishedIsEditing)
            ),
            rows: viewModel.venueHistories.map { .venueHistory($0) }
        )
        
        return [postCodeSection, testResultSection, symptomsOnsetSection, exposureNotificationSection, venueOfRiskDateSection, lastDayOfSelfIsolationSection, dailyTestingOptInSection, venueHistories].compactMap { $0 }
    }
    
    private var cancellable: AnyCancellable?
    
    public init(viewModel: ViewModel, interactor: Interacting) {
        self.viewModel = viewModel
        self.interactor = interactor
        super.init(style: .grouped)
        
        cancellable = $publishedIsEditing.sink { [weak self] editing in
            self?.tableView.setEditing(editing, animated: true)
        }
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
        case .postcode(let postcode, let localAuthority):
            cell = PostcodeCell.create(tableView: tableView, postcode: postcode, localAuthority: localAuthority)
        case .testDate(let date):
            cell = DateCell.create(tableView: tableView, title: localize(.mydata_test_result_test_date), date: date)
        case .testResult(let result):
            cell = TextCell.create(tableView: tableView, title: localize(.mydata_test_result_test_result), value: result.description)
        case .testKitType(let testKitType):
            cell = TextCell.create(tableView: tableView, title: localize(.mydata_test_result_test_kit_type), value: testKitType.description)
        case .confirmationStatus(let confirmationStatus):
            cell = TextCell.create(tableView: tableView, title: localize(.mydata_test_result_follow_up_test), value: confirmationStatus.description, subtitle: confirmationStatus.subtitle)
        case .symptomsOnsetDate(let date):
            cell = DateCell.create(tableView: tableView, title: localize(.mydata_section_date_description), date: date)
        case .venueHistory(let venueHistory):
            cell = VenueHistoryCell.create(tableView: tableView, venueHistory: venueHistory)
        case .lastDayOfSelfIsolation(let date):
            #warning("Find a safer day of doing this")
            // We should show the last day of isolation, not the first day after isolation, hence the going backward.
            // From a date calculation point of view this is correct, however this is somewhat error prone, so would be
            // better to resolve this in a different way.
            //
            // One possible solution is to send a `GregorianDay` to this field instead of a `Date` so we can specify
            // the actual "day isolation ends" instead of "moment isolation ends".
            let justBeforeEndOfIsolation = date.advanced(by: -1)
            cell = DateCell.create(tableView: tableView, title: localize(.mydata_section_date_description), date: justBeforeEndOfIsolation)
        case .dailyTestingOptIn(let date):
            cell = DateCell.create(tableView: tableView, title: localize(.mydata_daily_testing_opt_in_date_description), date: date)
        case .venueOfRiskDate(let date):
            cell = DateCell.create(tableView: tableView, title: localize(.mydata_section_date_description), date: date)
        case .encounterDate(let date):
            cell = DateCell.create(tableView: tableView, title: localize(.mydata_exposure_notification_details_exposure_date_description), date: date)
        case .notificationDate(let date):
            cell = DateCell.create(tableView: tableView, title: localize(.mydata_exposure_notification_details_notification_date_description), date: date)
        }
        
        // Trigger a layout pass to prevent incorrect cell content layout
        cell.setNeedsDisplay()
        cell.layoutIfNeeded()
        return cell
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        title = localize(.mydata_title)
        view.styleAsScreenBackground(with: traitCollection)
        
        tableView.sectionHeaderHeight = UITableView.automaticDimension
        tableView.sectionFooterHeight = .zero
        tableView.rowHeight = UITableView.automaticDimension
        tableView.sectionFooterHeight = UITableView.automaticDimension
        
        tableView.register(EditableSectionHeader.self, forHeaderFooterViewReuseIdentifier: EditableSectionHeader.reuseIdentifier)
        tableView.register(SectionHeader.self, forHeaderFooterViewReuseIdentifier: SectionHeader.reuseIdentifier)
        tableView.register(PostcodeCell.self, forCellReuseIdentifier: PostcodeCell.reuseIdentifier)
        tableView.register(DateCell.self, forCellReuseIdentifier: DateCell.reuseIdentifier)
        tableView.register(VenueHistoryCell.self, forCellReuseIdentifier: VenueHistoryCell.reuseIdentifier)
    }
    
    override public func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        if section == (content.count - 1) {
            return TableViewFooter.create(tableView: tableView, action: showDeleteAlert)
        }
        return nil
    }
    
    private func showDeleteAlert() {
        let alertController = UIAlertController(
            title: localize(.mydata_delete_data_alert_title),
            message: localize(.mydata_delete_data_alert_description),
            preferredStyle: .alert
        )
        
        let deleteAction = UIAlertAction(title: localize(.mydata_delete_data_alert_button_title), style: .default) { [weak self] _ in
            self?.interactor.deleteAppData()
        }
        
        alertController.addAction(UIAlertAction(title: localize(.cancel), style: .default))
        alertController.addAction(deleteAction)
        alertController.preferredAction = deleteAction
        
        present(alertController, animated: true)
    }
    
    override public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        switch content[section].header {
        case .postcode(let title, let action):
            return EditableSectionHeader.create(tableView: tableView, title: title, action: action)
        case .venueHistory(let title, let action, let isEditing):
            return VenueHistorySectionHeader.create(tableView: tableView, title: title, action: action, isEditing: isEditing)
        case .basic(let title):
            return SectionHeader.create(tableView: tableView, title: title)
        }
    }
    
    override public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        if case .venueHistory(let venueHistory) = content[indexPath.section].rows[indexPath.row] {
            return UISwipeActionsConfiguration(actions: [
                UIContextualAction(style: .destructive, title: localize(.delete), handler: { [weak self] action, view, completion in
                    guard let self = self else {
                        completion(false)
                        return
                    }
                    self.deleteRow(for: venueHistory, at: indexPath)
                    completion(true)
                }),
            ])
        } else {
            return nil
        }
    }
    
    func deleteRow(for venueHistory: VenueHistory, at indexPath: IndexPath) {
        viewModel.venueHistories = interactor.updateVenueHistories(venueHistory)
        
        if viewModel.venueHistories.count == 0 {
            tableView.deleteSections([indexPath.section], with: .automatic)
        } else {
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
    }
    
    override public func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        if case .venueHistory = content[indexPath.section].rows[indexPath.row] {
            return true
        } else {
            return false
        }
    }
    
    override public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            switch content[indexPath.section].rows[indexPath.row] {
            case .venueHistory(let venueHistory):
                deleteRow(for: venueHistory, at: indexPath)
            case .postcode, .testDate, .testResult, .testKitType, .confirmationStatus, .symptomsOnsetDate, .encounterDate, .notificationDate, .lastDayOfSelfIsolation, .dailyTestingOptIn, .venueOfRiskDate:
                break
            }
        }
    }
    
    override public func tableView(_ tableView: UITableView, willBeginEditingRowAt indexPath: IndexPath) {
        super.tableView(tableView, willBeginEditingRowAt: indexPath)
        publishedIsEditing = true
    }
    
    override public func tableView(_ tableView: UITableView, didEndEditingRowAt indexPath: IndexPath?) {
        super.tableView(tableView, didEndEditingRowAt: indexPath)
        publishedIsEditing = false
    }
}
