//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Domain

public struct FeatureToggleStorage {
    
    @UserDefault("scenario.toggle.dailyContactTesting", defaultValue: Feature.productionEnabledFeatures.contains(.dailyContactTesting))
    public var dailyContactTestingToggle: Bool
    
    #warning("Retrieve key from UserDefault")
    public var allFeatureKeys: [String] {
        [$dailyContactTestingToggle.key]
    }
    
    public init() {}
    
    static func getEnabledFeatures() -> [Feature] {
        let store = FeatureToggleStorage()
        var enabledFeatures = [Feature]()
        
        if store.dailyContactTestingToggle {
            enabledFeatures.append(.dailyContactTesting)
        }
        
        return enabledFeatures
    }
}
