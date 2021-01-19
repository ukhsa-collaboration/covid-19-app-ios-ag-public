//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

public enum LanguageDirection {
    case unknown
    case leftToRight
    case rightToLeft
}

public func currentLanguageDirection(
    localeConfiguration: LocaleConfiguration? = nil,
    supportedLocalizations: [String] = Bundle.main.supportedLocalizations
) -> LanguageDirection {
    // Locale.lineDirection may send values `.bottomToTop` or `.topToBottom`
    // so going for characterDirection to determine the language direction.
    let direction = Locale.characterDirection(
        forLanguage: currentLocaleIdentifier(
            localeConfiguration: localeConfiguration,
            supportedLocalizations: supportedLocalizations
        )
    )
    switch direction {
    case .leftToRight: return .leftToRight
    case .rightToLeft: return .rightToLeft
    default: assertionFailure(); return .unknown
    }
}
