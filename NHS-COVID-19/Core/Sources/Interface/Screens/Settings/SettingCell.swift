//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import Localization
import UIKit

extension SettingsViewController {

    class TextCell: UITableViewCell {
        static let reuseIdentifier = String(describing: TextCell.self)
        let titleLabel: UILabel

        override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
            titleLabel = BaseLabel().styleAsBody()
            super.init(style: style, reuseIdentifier: reuseIdentifier)
            backgroundColor = UIColor(.surface)

            contentView.addAutolayoutSubview(titleLabel)

            let stackView = UIStackView.vertical(with: [titleLabel])
            contentView.addCellContentSubview(stackView)
        }

        private func setting(title: String) -> TextCell {
            titleLabel.set(text: title)
            return self
        }

        static func create(tableView: UITableView, title: String) -> TextCell {
            let dequeuedCell = tableView.dequeueReusableCell(withIdentifier: reuseIdentifier) as? TextCell ?? TextCell()
            dequeuedCell.accessoryType = .disclosureIndicator
            return dequeuedCell.setting(title: title)
        }

        required init?(coder: NSCoder) {
            fatalError("init(coder:) has not been implemented")
        }
    }
}
