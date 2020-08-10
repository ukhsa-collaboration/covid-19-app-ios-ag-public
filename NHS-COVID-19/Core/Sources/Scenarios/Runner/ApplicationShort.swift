//
// Copyright © 2020 NHSX. All rights reserved.
//

import Integration
import UIKit

struct ApplicationShort {
    var item: UIApplicationShortcutItem
    var action: () -> Void
}

extension ApplicationShort {
    init(type: String, title: String, systemImageName: String, action: @escaping () -> Void) {
        let icon: UIApplicationShortcutIcon?
        if #available(iOS 13.0, *) {
            icon = UIApplicationShortcutIcon(systemImageName: systemImageName)
        } else {
            icon = nil
        }
        self.init(
            item: UIApplicationShortcutItem(
                type: type,
                localizedTitle: title,
                localizedSubtitle: nil,
                icon: icon,
                userInfo: nil
            ),
            action: action
        )
    }
}
