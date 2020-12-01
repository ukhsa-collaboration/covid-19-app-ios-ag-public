//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Domain

struct FeatureToggleStorage {
    
    @UserDefault("scenario.toggle.localAuthority", defaultValue: Feature.productionEnabledFeatures.contains(.localAuthority))
    var localAuthorityToggle: Bool
    
    static func getEnabledFeatures() -> [Feature] {
        let store = FeatureToggleStorage()
        var enabledFeatures = [Feature]()
        
        if store.localAuthorityToggle {
            enabledFeatures.append(.localAuthority)
        }
        return enabledFeatures
    }
    
}
