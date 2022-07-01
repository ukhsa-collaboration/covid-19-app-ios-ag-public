//
// Copyright © 2021 DHSC. All rights reserved.
//

import Foundation
import Localization

public class ShowLocalizableKeysOnlyOverrider: LocalizationOverrider {

    public init() {}

    public func localize(_ key: String, languageCode: String, tableName: String?, bundle: Bundle, value: String, comment: String) -> String? {
        return key
    }

}
