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
    
    @UserDefault("scenario.toggle.englandOptOutFlow", defaultValue: Feature.productionEnabledFeatures.contains(.contactOptOutFlowEngland))
    public var englandOptOutFlowToggle: Bool
    
    @UserDefault("scenario.toggle.walesOptOutFlow", defaultValue: Feature.productionEnabledFeatures.contains(.contactOptOutFlowWales))
    public var walesOptOutFlowToggle: Bool
    
    @UserDefault("scenario.toggle.testingForCOVID19", defaultValue: Feature.productionEnabledFeatures.contains(.testingForCOVID19))
    public var testingForCOVID19Toggle: Bool
    
    @UserDefault("scenario.toggle.selfIsolationToggleEngland", defaultValue: Feature.productionEnabledFeatures.contains(.selfIsolationHubEngland))
    public var selfIsolationHubToggleEngland: Bool
    
    @UserDefault("scenario.toggle.selfIsolationToggleWales", defaultValue: Feature.productionEnabledFeatures.contains(.selfIsolationHubWales))
    public var selfIsolationHubToggleWales: Bool
    
    @UserDefault("scenario.toggle.guidanceHubEnglandToggle", defaultValue: Feature.productionEnabledFeatures.contains(.guidanceHubEngland))
    public var guidanceHubEnglandToggle: Bool
    
    @UserDefault("scenario.toggle.guidanceHubWalesToggle", defaultValue: Feature.productionEnabledFeatures.contains(.guidanceHubWales))
    public var guidanceHubWalesToggle: Bool
    
    #warning("Retrieve key from UserDefault")
    public var allFeatureKeys: [String] {
        [
            $newNoSymptomsScreenToggle.key,
            $localStatisticsToggle.key,
            $venueCheckInToggle.key,
            $englandOptOutFlowToggle.key,
            $walesOptOutFlowToggle.key,
            $testingForCOVID19Toggle.key,
            $selfIsolationHubToggleEngland.key,
            $selfIsolationHubToggleWales.key,
            $guidanceHubEnglandToggle.key,
            $guidanceHubWalesToggle.key,
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
        
        if store.englandOptOutFlowToggle {
            enabledFeatures.append(.contactOptOutFlowEngland)
        }
        
        if store.walesOptOutFlowToggle {
            enabledFeatures.append(.contactOptOutFlowWales)
        }
        
        if store.testingForCOVID19Toggle {
            enabledFeatures.append(.testingForCOVID19)
        }
        
        if store.selfIsolationHubToggleEngland {
            enabledFeatures.append(.selfIsolationHubEngland)
        }
        
        if store.selfIsolationHubToggleWales {
            enabledFeatures.append(.selfIsolationHubWales)
        }
        
        if store.guidanceHubEnglandToggle {
            enabledFeatures.append(.guidanceHubEngland)
        }
        
        if store.guidanceHubWalesToggle {
            enabledFeatures.append(.guidanceHubWales)
        }
        
        return enabledFeatures
    }
}
