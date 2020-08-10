//
// Copyright © 2020 NHSX. All rights reserved.
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
    
    private let sections: [ListSection]
    
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
    
    private func row(at indexPath: IndexPath) -> ListRow {
        sections[indexPath.section].rows[indexPath.row]
    }
    
}
