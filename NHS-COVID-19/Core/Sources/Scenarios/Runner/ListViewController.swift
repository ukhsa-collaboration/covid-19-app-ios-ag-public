//
// Copyright © 2022 DHSC. All rights reserved.
//

import UIKit

struct ListRow {
    var title: String
    var infoAction: (() -> Void)? = nil
    var action: () -> Void
}

struct ListSection {
    var title: String
    var rows: [ListRow]
}

class ListViewController: UITableViewController {

    private let cellReuseId = UUID().uuidString

    fileprivate var sections: [ListSection]

    init(title: String, sections: [ListSection]) {
        self.sections = sections
        super.init(style: .grouped)
        self.title = title
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        tableView.register(UITableViewCell.self, forCellReuseIdentifier: cellReuseId)
    }

    override func numberOfSections(in tableView: UITableView) -> Int {
        sections.count
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        sections[section].rows.count
    }

    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        sections[section].title
    }

    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellReuseId, for: indexPath)
        let row = self.row(at: indexPath)
        cell.textLabel?.text = row.title
        cell.accessoryType = (row.infoAction == nil) ? .none : .detailButton
        return cell
    }

    override func tableView(_ tableView: UITableView, accessoryButtonTappedForRowWith indexPath: IndexPath) {
        row(at: indexPath).infoAction?()
    }

    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        row(at: indexPath).action()
    }

    func row(at indexPath: IndexPath) -> ListRow {
        sections[indexPath.section].rows[indexPath.row]
    }

}

class SearchableListViewController: ListViewController, UISearchResultsUpdating, UISearchBarDelegate, UISearchControllerDelegate {
    var searchController: UISearchController!
    var resultsTableController = ListViewController(title: "Results", sections: [])

    override init(title: String, sections: [ListSection]) {
        super.init(title: title, sections: sections)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        resultsTableController.tableView.delegate = self

        searchController = UISearchController(searchResultsController: resultsTableController)
        searchController.delegate = self
        searchController.searchResultsUpdater = self
        searchController.searchBar.autocapitalizationType = .none
        searchController.searchBar.delegate = self

        navigationItem.searchController = searchController
    }

    func updateSearchResults(for searchController: UISearchController) {

        let searchTerms =
            searchController.searchBar.text!
                .trimmingCharacters(in: CharacterSet.whitespaces)
                .components(separatedBy: " ") as [String]

        let filteredResults = sections.map { section -> ListSection in
            let filteredRows = section.rows.filter { row in
                let lowercasedRowTitle = row.title.lowercased()
                return searchTerms.contains { lowercasedRowTitle.contains($0.lowercased()) }
            }
            return ListSection(title: section.title, rows: filteredRows)
        }.filter { $0.rows.count > 0 }

        resultsTableController.sections = filteredResults
        resultsTableController.tableView.reloadData()

    }

    override func row(at indexPath: IndexPath) -> ListRow {
        if searchController.isActive,
           resultsTableController.sections.count > indexPath.section,
           resultsTableController.sections[indexPath.section].rows.count > indexPath.row {
            return resultsTableController.sections[indexPath.section].rows[indexPath.row]
        } else {
            return super.row(at: indexPath)
        }
    }
}
