//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Localization
import UIKit

extension SettingsViewController {
    class TableViewFooter: UIView {
        var action: (() -> Void)?

        init() {
            super.init(frame: .zero)

            let deleteButton = UIButton()
            deleteButton.addTarget(self, action: #selector(act))
            deleteButton.setTitle(localize(.mydata_delete_and_reset_data_button_title), for: .normal)
            deleteButton.styleAsDestructive()

            addAutolayoutSubview(deleteButton)
            NSLayoutConstraint.activate([
                deleteButton.topAnchor.constraint(equalTo: topAnchor, constant: .doubleSpacing),
                deleteButton.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -.doubleSpacing)
                    .withPriority(.almostRequest),
                deleteButton.leadingAnchor.constraint(
                    equalTo: readableContentGuide.leadingAnchor,
                    constant: .doubleSpacing
                ),
                deleteButton.trailingAnchor.constraint(
                    equalTo: readableContentGuide.trailingAnchor,
                    constant: -.doubleSpacing
                ),
            ])
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
    }
}
