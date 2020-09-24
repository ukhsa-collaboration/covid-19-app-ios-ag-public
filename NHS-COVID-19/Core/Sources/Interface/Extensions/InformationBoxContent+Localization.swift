//
// Copyright © 2020 NHSX. All rights reserved.
//

import Localization
import UIKit

extension InformationBox.Content {
    static func title(_ key: StringLocalizationKey) -> Self {
        return .title(localize(key))
    }
    
    static func heading(_ key: StringLocalizationKey) -> Self {
        return .heading(localize(key))
    }
    
    static func body(_ key: StringLocalizationKey) -> Self {
        return .body(localize(key))
    }
    
    static func linkButton(_ key: StringLocalizationKey, image: UIImage? = UIImage(.externalLink), _ action: @escaping () -> Void) -> Self {
        .linkButton(localize(key), image, action)
    }
}

extension InformationBox.Content {
    static func title(_ key: ParameterisedStringLocalizable) -> Self {
        return .title(localize(key))
    }
    
    static func heading(_ key: ParameterisedStringLocalizable) -> Self {
        return .heading(localize(key))
    }
    
    static func body(_ key: ParameterisedStringLocalizable) -> Self {
        return .body(localize(key))
    }
    
    static func linkButton(_ key: ParameterisedStringLocalizable, _ image: UIImage? = UIImage(.externalLink), _ action: @escaping () -> Void) -> Self {
        .linkButton(localize(key), image, action)
        
    }
    
}
