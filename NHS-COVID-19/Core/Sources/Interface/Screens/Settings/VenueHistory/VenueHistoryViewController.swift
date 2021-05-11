//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Localization
import UIKit

public protocol VenueHistoryViewControllerInteracting {
    var updateVenueHistories: (VenueHistory) -> [VenueHistory] { get }
}

public class VenueHistoryViewController: UITableViewController {
    public class ViewModel {
        private let venueHistories: [LocalDay: [VenueHistory]]
        let headers: [LocalDay]
        
        var isEmpty: Bool {
            venueHistories.isEmpty
        }
        
        public init(venueHistories: [VenueHistory]) {
            let venueHistoriesDict = Dictionary(
                grouping: venueHistories,
                by: { LocalDay(date: $0.checkedIn, timeZone: .current) }
            ).mapValues { values in
                values.sorted {
                    if $0.checkedIn == $1.checkedIn {
                        return $0.organisation.lowercased() < $1.organisation.lowercased()
                    } else {
                        return $0.checkedIn > $1.checkedIn
                    }
                }
            }
            self.venueHistories = venueHistoriesDict
            headers = venueHistoriesDict.keys.sorted(by: >)
        }
        
        func venueHistories(by localDay: LocalDay) -> [VenueHistory] {
            guard let venueHistories = self.venueHistories[localDay] else {
                assertionFailure("This should never come here as the key localDay is extracted from the dictionary")
                return []
            }
            return venueHistories
        }
    }
    
    private var viewModel: ViewModel
    private let interactor: Interacting
    public typealias Interacting = VenueHistoryViewControllerInteracting
    
    public init(viewModel: ViewModel, interactor: VenueHistoryViewControllerInteracting) {
        self.viewModel = viewModel
        self.interactor = interactor
        super.init(style: .plain)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        super.viewDidLoad()
        title = localize(.settings_venue_history)
        view.styleAsScreenBackground(with: traitCollection)
        tableView.allowsSelection = false
        tableView.tableFooterView = UIView()
        tableView.rowHeight = UITableView.automaticDimension
        tableView.register(VenueHistoryCell.self, forCellReuseIdentifier: VenueHistoryCell.reuseIdentifier)
        tableView.register(VenueHistoryHeaderView.self, forHeaderFooterViewReuseIdentifier: VenueHistoryHeaderView.reuseIdentifier)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        _ = viewModel.isEmpty ? showEmptySettingsScreen() : showTableView()
    }
    
    override public func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.beginUpdates()
        tableView.endUpdates()
        navigationItem.rightBarButtonItem?.title = editing == true ? localize(.mydata_venue_history_done_button_title) : localize(.mydata_venue_history_edit_button_title)
    }
    
    private func showEmptySettingsScreen() {
        tableView.backgroundView = EmptySettingsView(image: UIImage(.settingInfo), description: localize(.settings_no_records))
        navigationItem.rightBarButtonItem = nil
        UIAccessibility.post(notification: .screenChanged, argument: localize(.settings_no_records))
    }
    
    private func showTableView() {
        navigationItem.rightBarButtonItem = editButtonItem
        navigationItem.rightBarButtonItem?.title = localize(.mydata_venue_history_edit_button_title)
        tableView.backgroundView = nil
    }
    
    private func didDeleteRiskyVenue(indexPath: IndexPath) {
        let localDay = viewModel.headers[indexPath.section]
        let rows = viewModel.venueHistories(by: localDay)
        let deletedRow = rows[indexPath.row]
        viewModel = ViewModel(venueHistories: interactor.updateVenueHistories(deletedRow))
        tableView.beginUpdates()
        tableView.deleteRows(at: [indexPath], with: .automatic)
        if rows.count == 1 {
            tableView.deleteSections(IndexSet(integer: indexPath.section), with: .automatic)
        }
        tableView.endUpdates()
        if viewModel.isEmpty {
            showEmptySettingsScreen()
        }
    }
    
    override public func numberOfSections(in tableView: UITableView) -> Int {
        return viewModel.headers.count
    }
    
    override public func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        let localDay = viewModel.headers[section]
        return viewModel.venueHistories(by: localDay).count
    }
    
    override public func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let localDay = viewModel.headers[indexPath.section]
        return VenueHistoryCell.create(tableView: tableView, venueHistory: viewModel.venueHistories(by: localDay)[indexPath.row])
    }
    
    override public func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCell.EditingStyle, forRowAt indexPath: IndexPath) {
        guard editingStyle == .delete else {
            return
        }
        didDeleteRiskyVenue(indexPath: indexPath)
    }
    
    override public func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let localDay = viewModel.headers[section]
        return VenueHistoryHeaderView.create(tableView: tableView, date: localDay.startOfDay)
    }
    
    override public func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        return UISwipeActionsConfiguration(actions: [
            UIContextualAction(style: .destructive, title: localize(.delete), handler: { [weak self] action, view, completion in
                guard let self = self else {
                    completion(false)
                    return
                }
                self.didDeleteRiskyVenue(indexPath: indexPath)
                completion(true)
            }),
        ])
    }
}

extension VenueHistoryViewController {
    class VenueHistoryHeaderView: UITableViewHeaderFooterView {
        static let reuseIdentifier = String(describing: VenueHistoryHeaderView.self)
        
        private let titleLabel: UILabel
        
        override init(reuseIdentifier: String?) {
            titleLabel = BaseLabel().styleAsBody()
            
            super.init(reuseIdentifier: reuseIdentifier)
            let uiViewBackground = UIView()
            uiViewBackground.backgroundColor = UIColor(.background)
            backgroundView = uiViewBackground
            contentView.backgroundColor = UIColor(.background)
            
            let cellStack = UIStackView.vertical(
                with: [titleLabel]
            )
            addAutolayoutSubview(cellStack)
            NSLayoutConstraint.activate([
                cellStack.topAnchor.constraint(equalTo: topAnchor, constant: -.hairSpacing),
                cellStack.bottomAnchor.constraint(equalTo: bottomAnchor, constant: .halfSpacing),
                cellStack.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor, constant: -.standardSpacing),
                cellStack.trailingAnchor.constraint(equalTo: readableContentGuide.trailingAnchor, constant: .standardSpacing),
            ])
            
            // This stops VoiceOver from announcing the heading's container view as a group.
            accessibilityTraits = [.header, .staticText]
            titleLabel.isAccessibilityElement = false
        }
        
        private func setting(date: Date) -> VenueHistoryHeaderView {
            titleLabel.set(text: localize(.mydata_date_description(date: date)))
            accessibilityLabel = localize(.venue_history_heading_accessibility_label(date: date))
            return self
        }
        
        static func create(tableView: UITableView, date: Date) -> VenueHistoryHeaderView {
            let dequeued = tableView.dequeueReusableHeaderFooterView(withIdentifier: reuseIdentifier) as? VenueHistoryHeaderView
            return (dequeued ?? VenueHistoryHeaderView()).setting(date: date)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
    
    class VenueHistoryCell: UITableViewCell {
        static let reuseIdentifier = String(describing: VenueHistoryCell.self)
        
        private let organisationLabel: UILabel
        private let venueIdLabel: UILabel
        private let postcodeLabel: UILabel
        private let dateLabel: UILabel
        
        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            organisationLabel = BaseLabel().styleAsHeading()
            venueIdLabel = BaseLabel().styleAsSecondaryBody()
            postcodeLabel = BaseLabel().styleAsSecondaryBody()
            dateLabel = BaseLabel().styleAsSecondaryBody()
            
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            backgroundColor = UIColor(.surface)
            
            contentView.addAutolayoutSubview(organisationLabel)
            contentView.addAutolayoutSubview(dateLabel)
            contentView.addAutolayoutSubview(venueIdLabel)
            contentView.addAutolayoutSubview(postcodeLabel)
            
            // prioritise the venueID over the postcode when using large text sizes
            venueIdLabel.resistsSizeChange()
            
            // prevent postcode from wrapping when using large text sizes
            postcodeLabel.numberOfLines = 1
            
            let headerStack = UIStackView.horizontal(
                with: [organisationLabel],
                layoutMargins: .zero,
                distribution: .fill
            )
            let mainInfoStack = UIStackView.horizontal(
                with: [postcodeLabel, venueIdLabel],
                layoutMargins: .zero,
                distribution: .fill
            )
            let cellStack = UIStackView.vertical(
                with: [headerStack, mainInfoStack, dateLabel],
                layoutMargins: UIEdgeInsets(top: .halfSpacing, left: .zero, bottom: .halfSpacing, right: .zero)
            )
            contentView.addCellContentSubview(cellStack)
        }
        
        private func setting(venueHistory: VenueHistory) -> VenueHistoryCell {
            organisationLabel.set(text: venueHistory.organisation)
            venueIdLabel.set(text: venueHistory.venueId)
                .accessibilitySpellOut()
            if let postcode = venueHistory.postcode {
                postcodeLabel.set(text: postcode)
                    .formatAsPostcode()
            } else {
                postcodeLabel.set(text: localize(.venue_history_postcode_unavailable))
            }
            dateLabel.set(text: localize(.mydata_date_interval_description(
                startdate: venueHistory.checkedIn,
                endDate: venueHistory.checkedOut
            )))
            return self
        }
        
        static func create(tableView: UITableView, venueHistory: VenueHistory) -> VenueHistoryCell {
            let dequeued = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? VenueHistoryCell
            return (dequeued ?? VenueHistoryCell()).setting(venueHistory: venueHistory)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
