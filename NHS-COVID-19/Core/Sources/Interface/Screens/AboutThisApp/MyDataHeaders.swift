//
// Copyright © 2021 DHSC. All rights reserved.
//

import Localization
import UIKit

extension MyDataViewController {
    class SectionHeader: UITableViewHeaderFooterView {
        static let reuseIdentifier = String(describing: SectionHeader.self)
        let label: UILabel

        override init(reuseIdentifier: String?) {
            label = BaseLabel().styleAsSectionHeader()

            super.init(reuseIdentifier: reuseIdentifier)

            addAutolayoutSubview(label)

            NSLayoutConstraint.activate([
                label.leadingAnchor.constraint(equalTo: readableContentGuide.leadingAnchor, constant: .standardSpacing),
                label.trailingAnchor.constraint(equalTo: readableContentGuide.trailingAnchor, constant: -.standardSpacing),

                heightAnchor.constraint(greaterThanOrEqualTo: label.heightAnchor, constant: .standardSpacing).withPriority(.almostRequest),
                heightAnchor.constraint(greaterThanOrEqualToConstant: .buttonMinimumHeight + .standardSpacing).withPriority(.almostRequest),

                label.centerYAnchor.constraint(equalTo: centerYAnchor),
            ])
        }

        private func setting(title: String) -> Self {
            label.set(text: title)
            return self
        }

        static func create(tableView: UITableView, title: String) -> MyDataViewController.SectionHeader {
            let dequeued = tableView.dequeueReusableHeaderFooterView(withIdentifier: SectionHeader.reuseIdentifier) as? SectionHeader
            return (dequeued ?? SectionHeader()).setting(title: title)
        }

        required init?(coder: NSCoder) { fatalError("init(coder:) has not been implemented") }
    }
}
