//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import Foundation

struct IsolationConfiguration: Equatable {
    var maxIsolation: DayDuration
    var contactCase: DayDuration
    var indexCaseSinceSelfDiagnosisOnset: DayDuration
    var indexCaseSinceSelfDiagnosisUnknownOnset: DayDuration
    var housekeepingDeletionPeriod: DayDuration
    var indexCaseSinceNPEXDayNoSelfDiagnosis: DayDuration
}

extension IsolationConfiguration: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case maxIsolation
        case contactCase
        case indexCaseSinceSelfDiagnosisOnset
        case indexCaseSinceSelfDiagnosisUnknownOnset
        case housekeepingDeletionPeriod
        case indexCaseSinceNPEXDayNoSelfDiagnosis
    }
    
    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        
        maxIsolation = try container.decode(DayDuration.self, forKey: .maxIsolation)
        contactCase = try container.decode(DayDuration.self, forKey: .contactCase)
        indexCaseSinceSelfDiagnosisOnset = try container.decode(DayDuration.self, forKey: .indexCaseSinceSelfDiagnosisOnset)
        indexCaseSinceSelfDiagnosisUnknownOnset = try container.decode(DayDuration.self, forKey: .indexCaseSinceSelfDiagnosisUnknownOnset)
        housekeepingDeletionPeriod = try container.decode(DayDuration.self, forKey: .housekeepingDeletionPeriod)
        
        // value of the "10" is the historical default value before we were persisting this field.
        indexCaseSinceNPEXDayNoSelfDiagnosis = try container.decodeIfPresent(DayDuration.self, forKey: .indexCaseSinceNPEXDayNoSelfDiagnosis) ?? 10
        
    }
    
    static let `default` = IsolationConfiguration(
        maxIsolation: 21,
        contactCase: 11,
        indexCaseSinceSelfDiagnosisOnset: 11,
        indexCaseSinceSelfDiagnosisUnknownOnset: 9,
        housekeepingDeletionPeriod: 14,
        indexCaseSinceNPEXDayNoSelfDiagnosis: 11
    )
}
