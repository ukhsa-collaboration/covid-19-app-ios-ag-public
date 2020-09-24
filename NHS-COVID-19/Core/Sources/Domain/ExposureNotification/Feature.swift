//
// Copyright © 2020 NHSX. All rights reserved.
//

import Foundation

public enum Feature: CaseIterable {
    case riskyPostcode
    case venueCheckIn
    case selfDiagnosis
    case selfDiagnosisUpload
    case selfIsolation
    case testKitOrder
    case pilotActivation
    
    public static let productionEnabledFeatures: [Feature] = [.riskyPostcode, .venueCheckIn, .selfDiagnosis, .selfDiagnosisUpload, .selfIsolation, .testKitOrder]
}
