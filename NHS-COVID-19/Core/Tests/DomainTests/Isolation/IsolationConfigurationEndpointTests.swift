//
// Copyright © 2022 DHSC. All rights reserved.
//

import Common
import TestSupport
import XCTest
@testable import Domain

class IsolationConfigurationEndpointTests: XCTestCase {

    private let endpoint = IsolationConfigurationEndpoint()

    func testEncoding() throws {
        let expected = HTTPRequest.get("/distribution/self-isolation")

        let actual = try endpoint.request(for: ())

        TS.assert(actual, equals: expected)
    }

    func testDecoding() throws {
        let response = HTTPResponse.ok(with: .json("""
        {
          "england": {
            "indexCaseSinceSelfDiagnosisOnset": 1,
            "indexCaseSinceSelfDiagnosisUnknownOnset": 2,
            "contactCase": 3,
            "maxIsolation": 4,
            "indexCaseSinceTestResultEndDate": 5,
            "testResultPollingTokenRetentionPeriod": 28
          },
          "wales_v2": {
            "indexCaseSinceSelfDiagnosisOnset": 2,
            "indexCaseSinceSelfDiagnosisUnknownOnset": 3,
            "contactCase": 4,
            "maxIsolation": 5,
            "indexCaseSinceTestResultEndDate": 6,
            "pendingTasksRetentionPeriod": 15,
            "testResultPollingTokenRetentionPeriod": 29
          }
        }
        """))

        let expected = EnglandAndWalesIsolationConfigurations(
            england: IsolationConfiguration(
                maxIsolation: 4,
                contactCase: 3,
                indexCaseSinceSelfDiagnosisOnset: 1,
                indexCaseSinceSelfDiagnosisUnknownOnset: 2,
                housekeepingDeletionPeriod: 14,
                indexCaseSinceNPEXDayNoSelfDiagnosis: 5,
                testResultPollingTokenRetentionPeriod: 28
            ),
            wales: IsolationConfiguration(
                maxIsolation: 5,
                contactCase: 4,
                indexCaseSinceSelfDiagnosisOnset: 2,
                indexCaseSinceSelfDiagnosisUnknownOnset: 3,
                housekeepingDeletionPeriod: 15,
                indexCaseSinceNPEXDayNoSelfDiagnosis: 6,
                testResultPollingTokenRetentionPeriod: 29
            )
        )

        TS.assert(try endpoint.parse(response), equals: expected)
    }

    func testDecodingWithHousekeepingPeriodProvided() throws {
        let response = HTTPResponse.ok(with: .json("""
        {
          "england": {
            "indexCaseSinceSelfDiagnosisOnset": 1,
            "indexCaseSinceSelfDiagnosisUnknownOnset": 2,
            "contactCase": 3,
            "maxIsolation": 4,
            "pendingTasksRetentionPeriod": 9,
            "indexCaseSinceTestResultEndDate": 5,
            "testResultPollingTokenRetentionPeriod": 60
          },
          "wales_v2": {
            "indexCaseSinceSelfDiagnosisOnset": 2,
            "indexCaseSinceSelfDiagnosisUnknownOnset": 3,
            "contactCase": 4,
            "maxIsolation": 5,
            "pendingTasksRetentionPeriod": 10,
            "indexCaseSinceTestResultEndDate": 6,
            "testResultPollingTokenRetentionPeriod": 61
          }
        }
        """))

        let expected = EnglandAndWalesIsolationConfigurations(
            england: IsolationConfiguration(
                maxIsolation: 4,
                contactCase: 3,
                indexCaseSinceSelfDiagnosisOnset: 1,
                indexCaseSinceSelfDiagnosisUnknownOnset: 2,
                housekeepingDeletionPeriod: 9,
                indexCaseSinceNPEXDayNoSelfDiagnosis: 5,
                testResultPollingTokenRetentionPeriod: 60
            ),
            wales: IsolationConfiguration(
                maxIsolation: 5,
                contactCase: 4,
                indexCaseSinceSelfDiagnosisOnset: 2,
                indexCaseSinceSelfDiagnosisUnknownOnset: 3,
                housekeepingDeletionPeriod: 10,
                indexCaseSinceNPEXDayNoSelfDiagnosis: 6,
                testResultPollingTokenRetentionPeriod: 61
            )
        )

        TS.assert(try endpoint.parse(response), equals: expected)
    }
}
