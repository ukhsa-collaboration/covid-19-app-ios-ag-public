//
// Copyright © 2022 DHSC. All rights reserved.
//

import Common
import Foundation

struct IsolationConfigurationEndpoint: HTTPEndpoint {
    
    func request(for input: Void) throws -> HTTPRequest {
        .get("/distribution/self-isolation")
    }
    
    func parse(_ response: HTTPResponse) throws -> EnglandAndWalesIsolationConfigurations {
        let payload = try JSONDecoder().decode(Payload.self, from: response.body.content)
        return EnglandAndWalesIsolationConfigurations(
            england: .init(payload: payload.england),
            wales: .init(payload: payload.wales)
        )
    }
}

private struct Payload: Codable {
    struct CountrySpecificValues: Codable {
        var maxIsolation: Int
        var contactCase: Int
        var indexCaseSinceSelfDiagnosisOnset: Int
        var indexCaseSinceSelfDiagnosisUnknownOnset: Int
        var pendingTasksRetentionPeriod: Int?
        var indexCaseSinceTestResultEndDate: Int
        var testResultPollingTokenRetentionPeriod: Int
    }
    
    var england: CountrySpecificValues
    var wales: CountrySpecificValues
}

extension IsolationConfiguration {
    fileprivate init(payload: Payload.CountrySpecificValues) {
        self.init(
            maxIsolation: DayDuration(payload.maxIsolation),
            contactCase: DayDuration(payload.contactCase),
            indexCaseSinceSelfDiagnosisOnset: DayDuration(payload.indexCaseSinceSelfDiagnosisOnset),
            indexCaseSinceSelfDiagnosisUnknownOnset: DayDuration(payload.indexCaseSinceSelfDiagnosisUnknownOnset),
            housekeepingDeletionPeriod: DayDuration(payload.pendingTasksRetentionPeriod ?? 14),
            indexCaseSinceNPEXDayNoSelfDiagnosis: DayDuration(payload.indexCaseSinceTestResultEndDate),
            testResultPollingTokenRetentionPeriod: DayDuration(payload.testResultPollingTokenRetentionPeriod)
        )
    }
}
