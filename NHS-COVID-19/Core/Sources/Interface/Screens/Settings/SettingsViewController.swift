//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import Localization
import UIKit

public protocol SettingsViewControllerInteracting {
    func didTapLanguage()
    func didTapManageMyData()
    func didTapMyArea()
    func didTapDeleteAppData()
    func didTapVenueHistory()
    func didTapAnimations()
}

public class SettingsViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    public typealias Interacting = SettingsViewControllerInteracting
    
    public class ViewModel {
        @InterfaceProperty
        var language: String?
        
        public init() {
            _language = .constant(
                SupportedLanguage.getLanguageTermsFrom(
                    localeIdentifier: currentLocaleIdentifier()
            )?.exonym ?? localize(.settings_language_en))
        }
    }
    
    private struct Section {
        var rows: [Row]
    }
    
    private enum Row {
        case language(InterfaceProperty<String?>)
        case manageMyData
        case myArea
        case venueHistory
        case animations
    }
    
    private var content: [Section] {
        let languageRow = Row.language(viewModel.$language)
        let manageMyDataRow = Row.manageMyData
        let venuHistoryRow = Row.venueHistory
        let myAreaRow: Row = .myArea
        let animations: Row = .animations
        let section = Section(rows: [languageRow, myAreaRow, manageMyDataRow, venuHistoryRow, animations])
        return [section]
    }
    
    private let viewModel: ViewModel
    private let interacting: Interacting
    
    public init(viewModel: ViewModel, interacting: Interacting) {
        self.viewModel = viewModel
        self.interacting = interacting
        super.init(nibName: nil, bundle: nil)
        title = localize(.settings_title)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override public func viewDidLoad() {
        let tableView = UITableView()
        view.styleAsScreenBackground(with: traitCollection)
        tableView.styleAsScreenBackground(with: traitCollection)
        let stackView = UIStackView.vertical(
            with: [
                tableView,
                TableViewFooter().setting(action: showDeleteAlert),
            ],
            layoutMargins: .zero
        )
        view.addFillingSubview(stackView)
        tableView.delegate = self
        tableView.dataSource = self
        tableView.tableFooterView = UIView()
        
        tableView.register(DetailTableViewCell.self, forCellReuseIdentifier: DetailTableViewCell.reuseIdentifier)
    }
    
    override public func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        navigationController?.setNavigationBarHidden(false, animated: animated)
    }
    
    public func tableView(
        _ tableView: UITableView,
        cellForRowAt indexPath: IndexPath
    ) -> UITableViewCell {
        let cell: UITableViewCell
        switch content[indexPath.section].rows[indexPath.row] {
        case .language(let language):
            cell = DetailTableViewCell.create(
                tableView: tableView,
                label: localize(.settings_row_language),
                value: language,
                withAccessoryType: true
            )
        case .manageMyData:
            cell = TextCell.create(tableView: tableView, title: localize(.settings_row_my_data_title))
        case .venueHistory:
            cell = TextCell.create(tableView: tableView, title: localize(.settings_venue_history))
        case .myArea:
            cell = TextCell.create(tableView: tableView, title: localize(.settings_row_my_area_title))
        case .animations:
            cell = TextCell.create(tableView: tableView, title: localize(.settings_row_animations_title))
        }
        return cell
    }
    
    public func numberOfSections(in tableView: UITableView) -> Int {
        return content.count
    }
    
    public func tableView(
        _ tableView: UITableView,
        numberOfRowsInSection section: Int
    ) -> Int {
        return content[section].rows.count
    }
    
    public func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        switch content[indexPath.section].rows[indexPath.row] {
        case .language: interacting.didTapLanguage()
        case .manageMyData: interacting.didTapManageMyData()
        case .myArea: interacting.didTapMyArea()
        case .venueHistory: interacting.didTapVenueHistory()
        case .animations: interacting.didTapAnimations()
        }
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    private func showDeleteAlert() {
        let alertController = UIAlertController(
            title: localize(.mydata_delete_data_alert_title),
            message: localize(.mydata_delete_data_alert_description),
            preferredStyle: .alert
        )
        
        let deleteAction = UIAlertAction(
            title: localize(.mydata_delete_data_alert_button_title),
            style: .default
        ) { [weak self] _ in
            self?.interacting.didTapDeleteAppData()
        }
        
        alertController.addAction(UIAlertAction(title: localize(.cancel), style: .default))
        alertController.addAction(deleteAction)
        alertController.preferredAction = deleteAction
        
        present(alertController, animated: true)
    }
}
