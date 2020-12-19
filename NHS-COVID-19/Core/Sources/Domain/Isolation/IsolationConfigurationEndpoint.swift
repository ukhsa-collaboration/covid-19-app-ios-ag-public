//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import Foundation

struct IsolationConfigurationEndpoint: HTTPEndpoint {
    
    func request(for input: Void) throws -> HTTPRequest {
        .get("/distribution/self-isolation")
    }
    
    func parse(_ response: HTTPResponse) throws -> IsolationConfiguration {
        let payload = try JSONDecoder().decode(Payload.self, from: response.body.content)
        let durations = payload.durationDays
        return IsolationConfiguration(
            maxIsolation: DayDuration(durations.maxIsolation),
            contactCase: DayDuration(durations.contactCase),
            indexCaseSinceSelfDiagnosisOnset: DayDuration(durations.indexCaseSinceSelfDiagnosisOnset),
            indexCaseSinceSelfDiagnosisUnknownOnset: DayDuration(durations.indexCaseSinceSelfDiagnosisUnknownOnset),
            housekeepingDeletionPeriod: DayDuration(durations.pendingTasksRetentionPeriod ?? 14),
            indexCaseSinceNPEXDayNoSelfDiagnosis: IsolationConfiguration.default.indexCaseSinceNPEXDayNoSelfDiagnosis
        )
    }
}

private struct Payload: Codable {
    struct DayDurations: Codable {
        var maxIsolation: Int
        var contactCase: Int
        var indexCaseSinceSelfDiagnosisOnset: Int
        var indexCaseSinceSelfDiagnosisUnknownOnset: Int
        var pendingTasksRetentionPeriod: Int?
    }
    
    var durationDays: DayDurations
}
