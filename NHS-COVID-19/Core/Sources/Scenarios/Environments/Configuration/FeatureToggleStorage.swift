//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Domain

struct FeatureToggleStorage {
    @UserDefault("scenario.toggle.self_diagnosis", defaultValue: Feature.productionEnabledFeatures.contains(.selfDiagnosis))
    var selfDiagnosisToggle: Bool
    
    @UserDefault("scenario.toggle.self_diagnosis_upload", defaultValue: Feature.productionEnabledFeatures.contains(.selfDiagnosisUpload))
    var selfDiagnosisUploadToggle: Bool
    
    @UserDefault("scenario.toggle.self_isolation", defaultValue: Feature.productionEnabledFeatures.contains(.selfIsolation))
    var selfIsolationToggle: Bool
    
    @UserDefault("scenario.toggle.test_kit_order", defaultValue: Feature.productionEnabledFeatures.contains(.testKitOrder))
    var testKitOrderToggle: Bool
    
    static func getEnabledFeatures() -> [Feature] {
        let store = FeatureToggleStorage()
        var enabledFeatures = [Feature]()
        
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
