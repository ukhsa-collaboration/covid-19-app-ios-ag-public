//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Localization
import UIKit

extension UIView {

    public func styleAsScreenBackground(with traitCollection: UITraitCollection) {
        backgroundColor = UIColor(.background)
    }

    public func applySemanticContentAttribute(configuration: LocaleConfiguration? = nil) {
        switch currentLanguageDirection(localeConfiguration: configuration) {
        case .leftToRight:
            semanticContentAttribute = .forceLeftToRight
        case .rightToLeft:
            semanticContentAttribute = .forceRightToLeft
        case .unknown:
            break
        }
    }

}
