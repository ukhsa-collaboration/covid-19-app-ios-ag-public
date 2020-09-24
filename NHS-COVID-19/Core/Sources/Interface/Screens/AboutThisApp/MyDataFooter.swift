//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Localization
import UIKit

extension MyDataViewController {
    class TableViewFooter: UITableViewHeaderFooterView {
        static let reuseIdentifier = String(describing: self)
        var action: (() -> Void)?
        
        override init(reuseIdentifier: String?) {
            super.init(reuseIdentifier: reuseIdentifier)
            
            let deleteButton = UIButton()
            deleteButton.addTarget(self, action: #selector(act))
            deleteButton.setTitle(localize(.mydata_data_deletion_button_title), for: .normal)
            deleteButton.styleAsDestructive()
            
            addCellContentSubview(deleteButton, inset: .doubleSpacing)
        }
        
        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
        
        @objc private func act() {
            action?()
        }
        
        func setting(action: @escaping () -> Void) -> Self {
            self.action = action
            return self
        }
        
        static func create(tableView: UITableView, action: @escaping () -> Void) -> Self {
            let dequeued = tableView.dequeueReusableHeaderFooterView(withIdentifier: TableViewFooter.reuseIdentifier) as? Self
            return (dequeued ?? Self()).setting(action: action)
        }
    }
}
