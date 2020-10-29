//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import TestSupport
import XCTest
@testable import Domain

class CircuitBreakerApprovalEndpointTests: XCTestCase {
    
    private let riskInfo = RiskInfo(riskScore: 8, riskScoreVersion: 1, day: GregorianDay.today.advanced(by: -2))
    private let endpoint = CircuitBreakerApprovalEndpoint()
    typealias Response = CircuitBreakerApprovalEndpoint.Response
    
    func testEncodingRiskyVenue() throws {
        let venueId = String.random()
        let expected = HTTPRequest.post("/circuit-breaker/venue/request", body: .json(#"""
        {
          "venueId" : "\#(venueId)"
        }
        """#))
            .withCanonicalJSONBody()
        
        let actual = try endpoint.request(for: .riskyVenue(venueId)).withCanonicalJSONBody()
        TS.assert(actual, equals: expected)
    }
    
    func testEncodingExposureNotification() throws {
        let expected = HTTPRequest.post("/circuit-breaker/exposure-notification/request", body: .json(#"""
        {
            "matchedKeyCount" : 1,
            "daysSinceLastExposure": 2,
            "maximumRiskScore" : 8,
            "riskCalculationVersion": 1
        }
        """#))
            .withCanonicalJSONBody()
        
        let actual = try endpoint.request(for: .exposureNotification(riskInfo)).withCanonicalJSONBody()
        TS.assert(actual, equals: expected)
    }
    
    func testDecodingApproved() throws {
        let approvalTokenString = UUID().uuidString
        
        let httpResponse = HTTPResponse(
            statusCode: 200,
            body: .json("""
            {
                "approval_token": "\(approvalTokenString)",
                "approval": "yes"
            }
            """)
        )
        
        let expected = Response(approvalToken: .init(approvalTokenString), approval: .yes)
        let actual = try endpoint.parse(httpResponse)
        
        TS.assert(expected, equals: actual)
    }
    
    func testDecodingNotApproved() throws {
        let approvalTokenString = UUID().uuidString
        
        let httpResponse = HTTPResponse(
            statusCode: 200,
            body: .json("""
            {
                "approval_token": "\(approvalTokenString)",
                "approval": "no"
            }
            """)
        )
        
        let expected = Response(approvalToken: .init(approvalTokenString), approval: .no)
        let actual = try endpoint.parse(httpResponse)
        
        TS.assert(expected, equals: actual)
    }
    
    func testDecodingPending() throws {
        let approvalTokenString = UUID().uuidString
        
        let httpResponse = HTTPResponse(
            statusCode: 200,
            body: .json("""
            {
                "approval_token": "\(approvalTokenString)",
                "approval": "pending"
            }
            """)
        )
        
        let expected = Response(approvalToken: .init(approvalTokenString), approval: .pending)
        let actual = try endpoint.parse(httpResponse)
        
        TS.assert(expected, equals: actual)
    }
    
}
