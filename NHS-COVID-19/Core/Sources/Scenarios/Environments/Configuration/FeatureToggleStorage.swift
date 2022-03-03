//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Domain

public struct FeatureToggleStorage {
    
    @UserDefault("scenario.toggle.newNoSymptomsScreen", defaultValue: Feature.productionEnabledFeatures.contains(.newNoSymptomsScreen))
    public var newNoSymptomsScreenToggle: Bool
    
    @UserDefault("scenario.toggle.localStatistic", defaultValue: Feature.productionEnabledFeatures.contains(.localStatistics))
    public var localStatisticsToggle: Bool
    
    @UserDefault("scenario.toggle.venueCheckIn", defaultValue: Feature.productionEnabledFeatures.contains(.venueCheckIn))
    public var venueCheckInToggle: Bool
    
    #warning("Retrieve key from UserDefault")
    public var allFeatureKeys: [String] {
        [
            $newNoSymptomsScreenToggle.key,
            $localStatisticsToggle.key,
            $venueCheckInToggle.key,
        ]
    }
    
    public init() {}
    
    static func getEnabledFeatures() -> [Feature] {
        let store = FeatureToggleStorage()
        var enabledFeatures = [Feature]()
        
        if store.newNoSymptomsScreenToggle {
            enabledFeatures.append(.newNoSymptomsScreen)
        }
        
        if store.localStatisticsToggle {
            enabledFeatures.append(.localStatistics)
        }
        
        if store.venueCheckInToggle {
            enabledFeatures.append(.venueCheckIn)
        }
        
        return enabledFeatures
    }
}
