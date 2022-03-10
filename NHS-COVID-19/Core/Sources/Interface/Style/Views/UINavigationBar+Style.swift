//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import UIKit

extension UINavigationBar {
    @discardableResult
    func styleAsTransparent() -> Self {
        tintColor = UIColor(.nhsBlue)
        if #available(iOS 15, *) {
            let appearance = UINavigationBarAppearance()
            appearance.configureWithOpaqueBackground()
            appearance.backgroundImage = UIImage()
            appearance.backgroundColor = .clear
            appearance.shadowImage = UIImage()
            appearance.shadowColor = .clear
            standardAppearance = appearance
            compactAppearance = appearance
            scrollEdgeAppearance = appearance
        } else {
            setBackgroundImage(UIImage(), for: .default)
            shadowImage = UIImage()
            isTranslucent = true
        }
        return self
    }
}
