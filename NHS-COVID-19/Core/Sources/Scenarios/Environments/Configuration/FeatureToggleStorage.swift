//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Domain

public struct FeatureToggleStorage {
    
    @UserDefault("scenario.toggle.newNoSymptomsScreen", defaultValue: Feature.productionEnabledFeatures.contains(.newNoSymptomsScreen))
    public var newNoSymptomsScreenToggle: Bool
    
    @UserDefault("scenario.toggle.bluetoothOff", defaultValue: Feature.productionEnabledFeatures.contains(.bluetoothOff))
    public var bluetoothOffToggle: Bool
    
    #warning("Retrieve key from UserDefault")
    public var allFeatureKeys: [String] {
        [
            $newNoSymptomsScreenToggle.key,
            $bluetoothOffToggle.key,
        ]
    }
    
    public init() {}
    
    static func getEnabledFeatures() -> [Feature] {
        let store = FeatureToggleStorage()
        var enabledFeatures = [Feature]()
        
        if store.newNoSymptomsScreenToggle {
            enabledFeatures.append(.newNoSymptomsScreen)
        }
        
        if store.bluetoothOffToggle {
            enabledFeatures.append(.bluetoothOff)
        }
        
        return enabledFeatures
    }
}
