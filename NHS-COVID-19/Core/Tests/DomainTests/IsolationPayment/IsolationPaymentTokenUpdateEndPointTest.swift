//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import TestSupport
import XCTest
@testable import Domain

class IsolationPaymentTokenUpdateEndPointTest: XCTestCase {
    
    func testEncoding() throws {
        
        let endpoint = IsolationPaymentTokenUpdateEndpoint()
        
        let riskyEncounterDay = GregorianDay(year: 2020, month: 11, day: 23)
        
        let islationEndsAtStartOfDay = GregorianDay(year: 2020, month: 11, day: 27)
        
        let isolationPaymentUpdate = IsolationPaymentTokenUpdate(ipcToken: "7fde14a2ee03611b0b511c8f88b3e6d49b658ad5002c3a5fb81d25ab54d4b8ac", riskyEncounterDay: riskyEncounterDay, isolationPeriodEndsAtStartOfDay: islationEndsAtStartOfDay)
        
        let actual = try endpoint.request(for: isolationPaymentUpdate).withCanonicalJSONBody()
        
        let expected = HTTPRequest.post("/isolation-payment/ipc-token/update", body: .json("""
        {
          "ipcToken": "\(isolationPaymentUpdate.ipcToken)",
          "riskyEncounterDate": "2020-11-23T00:00:00Z",
          "isolationPeriodEndDate": "2020-11-27T00:00:00Z",
        }
        """)).withCanonicalJSONBody()
        
        TS.assert(actual, equals: expected)
    }
    
    func testDecodingWithValidWebsiteURL() throws {
        let endpoint = IsolationPaymentTokenUpdateEndpoint()
        
        let expected = URL(string: "https://example.com/example?ipcToken=7fde14a2ee03611b0b511c8f88b3e6d49b658ad5002c3a5fb81d25ab54d4b8ac")!
        
        let response = HTTPResponse.ok(with: .json("""
        {
            "websiteUrlWithQuery": "https://example.com/example?ipcToken=7fde14a2ee03611b0b511c8f88b3e6d49b658ad5002c3a5fb81d25ab54d4b8ac"
        }
        """))
        
        let actual = try endpoint.parse(response)
        TS.assert(actual, equals: expected)
    }
    
    func testDecodingWithEmptyWebsiteURL() throws {
        let endpoint = IsolationPaymentTokenUpdateEndpoint()
        
        let response = HTTPResponse.ok(with: .json("""
        {
            "websiteUrlWithQuery": ""
        }
        """))
        XCTAssertThrowsError(try endpoint.parse(response))
    }
}
