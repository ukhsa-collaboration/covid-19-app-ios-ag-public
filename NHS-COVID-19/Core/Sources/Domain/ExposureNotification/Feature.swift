//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

public enum Feature: CaseIterable {
    case selfDiagnosis
    case selfDiagnosisUpload
    case selfIsolation
    case testKitOrder
    
    public static let productionEnabledFeatures: [Feature] = [.selfDiagnosis, .selfDiagnosisUpload, .selfIsolation, .testKitOrder]
}
