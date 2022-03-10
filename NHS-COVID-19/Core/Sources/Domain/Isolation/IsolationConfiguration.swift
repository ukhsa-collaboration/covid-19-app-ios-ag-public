//
// Copyright © 2022 DHSC. All rights reserved.
//

import Common
import Foundation

struct EnglandAndWalesIsolationConfigurations: Equatable {
    var england: IsolationConfiguration
    var wales: IsolationConfiguration
}

struct IsolationConfiguration: Equatable {
    var maxIsolation: DayDuration
    var contactCase: DayDuration
    var indexCaseSinceSelfDiagnosisOnset: DayDuration
    var indexCaseSinceSelfDiagnosisUnknownOnset: DayDuration
    var housekeepingDeletionPeriod: DayDuration
    var indexCaseSinceNPEXDayNoSelfDiagnosis: DayDuration
    var testResultPollingTokenRetentionPeriod: DayDuration
}

extension IsolationConfiguration: Codable {
    
    private enum CodingKeys: String, CodingKey {
        case maxIsolation
        case contactCase
        case indexCaseSinceSelfDiagnosisOnset
        case indexCaseSinceSelfDiagnosisUnknownOnset
        case housekeepingDeletionPeriod
        case indexCaseSinceNPEXDayNoSelfDiagnosis
        case testResultPollingTokenRetentionPeriod
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
        
        // value of the "28" is the historical default value before we were persisting this field.
        testResultPollingTokenRetentionPeriod = try container.decodeIfPresent(DayDuration.self, forKey: .testResultPollingTokenRetentionPeriod) ?? 28
    }
    
    static let `defaultEngland` = IsolationConfiguration(
        maxIsolation: 21,
        contactCase: 11,
        indexCaseSinceSelfDiagnosisOnset: 11,
        indexCaseSinceSelfDiagnosisUnknownOnset: 9,
        housekeepingDeletionPeriod: 14,
        indexCaseSinceNPEXDayNoSelfDiagnosis: 11,
        testResultPollingTokenRetentionPeriod: 28
    )
    
    static let `defaultWales` = IsolationConfiguration(
        maxIsolation: 16,
        contactCase: 11,
        indexCaseSinceSelfDiagnosisOnset: 6,
        indexCaseSinceSelfDiagnosisUnknownOnset: 4,
        housekeepingDeletionPeriod: 14,
        indexCaseSinceNPEXDayNoSelfDiagnosis: 6,
        testResultPollingTokenRetentionPeriod: 28
    )
}

extension EnglandAndWalesIsolationConfigurations {
    static let `default` = EnglandAndWalesIsolationConfigurations(england: .defaultEngland, wales: .defaultWales)
}
