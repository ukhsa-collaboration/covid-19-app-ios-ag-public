//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Domain

public struct FeatureToggleStorage {
    
    @UserDefault("scenario.toggle.newNoSymptomsScreen", defaultValue: Feature.productionEnabledFeatures.contains(.newNoSymptomsScreen))
    public var newNoSymptomsScreenToggle: Bool
    
    #warning("Retrieve key from UserDefault")
    public var allFeatureKeys: [String] {
        [$newNoSymptomsScreenToggle.key]
    }
    
    public init() {}
    
    static func getEnabledFeatures() -> [Feature] {
        let store = FeatureToggleStorage()
        var enabledFeatures = [Feature]()
        
        if store.newNoSymptomsScreenToggle {
            enabledFeatures.append(.newNoSymptomsScreen)
        }
        
        return enabledFeatures
    }
}
