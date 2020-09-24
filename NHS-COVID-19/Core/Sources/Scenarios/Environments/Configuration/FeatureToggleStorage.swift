//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Domain

struct FeatureToggleStorage {
    @UserDefault("scenario.toggle.risky_postcode", defaultValue: Feature.productionEnabledFeatures.contains(.riskyPostcode))
    var riskyPostcodeToggle: Bool
    
    @UserDefault("scenario.toggle.venue_check_in", defaultValue: Feature.productionEnabledFeatures.contains(.venueCheckIn))
    var venueCheckInToggle: Bool
    
    @UserDefault("scenario.toggle.self_diagnosis", defaultValue: Feature.productionEnabledFeatures.contains(.selfDiagnosis))
    var selfDiagnosisToggle: Bool
    
    @UserDefault("scenario.toggle.self_diagnosis_upload", defaultValue: Feature.productionEnabledFeatures.contains(.selfDiagnosisUpload))
    var selfDiagnosisUploadToggle: Bool
    
    @UserDefault("scenario.toggle.self_isolation", defaultValue: Feature.productionEnabledFeatures.contains(.selfIsolation))
    var selfIsolationToggle: Bool
    
    @UserDefault("scenario.toggle.test_kit_order", defaultValue: Feature.productionEnabledFeatures.contains(.testKitOrder))
    var testKitOrderToggle: Bool
    
    @UserDefault("scenario.toggle.pilot_activation", defaultValue: Feature.productionEnabledFeatures.contains(.pilotActivation))
    var pilotActivationToggle: Bool
    
    static func getEnabledFeatures() -> [Feature] {
        let store = FeatureToggleStorage()
        var enabledFeatures = [Feature]()
        
        if store.riskyPostcodeToggle {
            enabledFeatures.append(.riskyPostcode)
        }
        if store.venueCheckInToggle {
            enabledFeatures.append(.venueCheckIn)
        }
        if store.selfDiagnosisToggle {
            enabledFeatures.append(.selfDiagnosis)
        }
        if store.selfDiagnosisUploadToggle {
            enabledFeatures.append(.selfDiagnosisUpload)
        }
        if store.selfIsolationToggle {
            enabledFeatures.append(.selfIsolation)
        }
        if store.testKitOrderToggle {
            enabledFeatures.append(.testKitOrder)
        }
        if store.pilotActivationToggle {
            enabledFeatures.append(.pilotActivation)
        }
        
        return enabledFeatures
    }
    
}
