//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import TestSupport
import XCTest
@testable import Domain

class ExposureNotificationCircuitBreakerResolutionEndpointTests: XCTestCase {
    
    private let riskInfo = RiskInfo(riskScore: 7.5, day: .init(year: 2020, month: 5, day: 5))
    private lazy var endpoint = CircuitBreakerResolutionEndpoint(type: .exposureNotification(self.riskInfo))
    typealias Payload = CircuitBreakerApprovalToken
    typealias Response = CircuitBreakerResolutionEndpoint.Response
    
    private func equalJSON(expected: Data, actual: Data) -> Bool {
        do {
            let expectedJSONObject = try JSONSerialization.jsonObject(with: expected) as? NSDictionary
            let actualJSONObject = try JSONSerialization.jsonObject(with: actual) as? NSDictionary
            return expectedJSONObject == actualJSONObject
        } catch {
            return false
        }
    }
    
    func testEncoding() throws {
        let approvalTokenString = UUID().uuidString
        
        let expected = HTTPRequest.get("/circuit-breaker/exposure-notification/resolution/\(approvalTokenString)")
        let actual = try endpoint.request(for: Payload(approvalTokenString))
        TS.assert(actual, equals: expected)
    }
    
    func testDecoding() throws {
        let httpResponse = HTTPResponse(
            statusCode: 200,
            body: .json("""
            {
                "approval": "yes"
            }
            """)
        )
        
        let expected = Response(approval: .yes)
        let actual = try endpoint.parse(httpResponse)
        
        TS.assert(expected, equals: actual)
    }
    
}
