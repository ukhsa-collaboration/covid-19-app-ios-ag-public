//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Domain

struct FeatureToggleStorage {
    @UserDefault("scenario.toggle.risky_postcode", defaultValue: true)
    var riskyPostcodeToggle: Bool
    
    @UserDefault("scenario.toggle.venue_check_in", defaultValue: true)
    var venueCheckInToggle: Bool
    
    @UserDefault("scenario.toggle.self_diagnosis", defaultValue: true)
    var selfDiagnosisToggle: Bool
    
    @UserDefault("scenario.toggle.self_diagnosis_upload", defaultValue: true)
    var selfDiagnosisUploadToggle: Bool
    
    @UserDefault("scenario.toggle.self_isolation", defaultValue: true)
    var selfIsolationToggle: Bool
    
    @UserDefault("scenario.toggle.test_kit_order", defaultValue: true)
    var testKitOrderToggle: Bool
    
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
        return enabledFeatures
    }
    
}
