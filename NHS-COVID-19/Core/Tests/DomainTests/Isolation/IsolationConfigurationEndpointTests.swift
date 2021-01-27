//
// Copyright © 2020 NHSX. All rights reserved.
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
          "durationDays": {
            "indexCaseSinceSelfDiagnosisOnset": 1,
            "indexCaseSinceSelfDiagnosisUnknownOnset": 2,
            "contactCase": 3,
            "maxIsolation": 4,
            "indexCaseSinceTestResultEndDate": 5
          }
        }
        
        """))
        
        let expected = IsolationConfiguration(
            maxIsolation: 4,
            contactCase: 3,
            indexCaseSinceSelfDiagnosisOnset: 1,
            indexCaseSinceSelfDiagnosisUnknownOnset: 2,
            housekeepingDeletionPeriod: 14,
            indexCaseSinceNPEXDayNoSelfDiagnosis: 5
        )
        
        TS.assert(try endpoint.parse(response), equals: expected)
    }
    
    func testDecodingWithHousekeepingPeriodProvided() throws {
        let response = HTTPResponse.ok(with: .json("""
        {
          "durationDays": {
            "indexCaseSinceSelfDiagnosisOnset": 1,
            "indexCaseSinceSelfDiagnosisUnknownOnset": 2,
            "contactCase": 3,
            "maxIsolation": 4,
            "pendingTasksRetentionPeriod": 9,
            "indexCaseSinceTestResultEndDate": 5
          }
        }
        
        """))
        
        let expected = IsolationConfiguration(
            maxIsolation: 4,
            contactCase: 3,
            indexCaseSinceSelfDiagnosisOnset: 1,
            indexCaseSinceSelfDiagnosisUnknownOnset: 2,
            housekeepingDeletionPeriod: 9,
            indexCaseSinceNPEXDayNoSelfDiagnosis: 5
        )
        
        TS.assert(try endpoint.parse(response), equals: expected)
    }
    
}
