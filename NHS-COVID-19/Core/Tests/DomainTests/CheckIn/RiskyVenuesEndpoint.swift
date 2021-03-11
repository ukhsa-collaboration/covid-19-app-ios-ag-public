//
// Copyright © 2021 DHSC. All rights reserved.
//

import Common
import TestSupport
import XCTest
@testable import Domain

class RiskyVenuesEndpointTests: XCTestCase {
    
    private let endpoint = RiskyVenuesEndpoint()
    
    func testEncoding() throws {
        let expected = HTTPRequest.get("/distribution/risky-venues")
        
        let actual = try endpoint.request(for: ())
        
        TS.assert(actual, equals: expected)
    }
    
    func testDecodingEmptyList() throws {
        let response = HTTPResponse.ok(with: .json(#"""
        {
            "venues" : []
        }
        """#))
        
        let postcodes = try endpoint.parse(response)
        
        XCTAssert(postcodes.isEmpty)
    }
    
    func testDecodingListWithVenuesWithoutMillisecondsInTime() throws {
        // we go from `String` to `Date` even in test to ensure same rounding as app
        let from = "2019-07-04T13:33:03Z"
        let until = "2019-07-04T13:33:03Z"
        let id = String.random()
        
        let response = HTTPResponse.ok(with: .json(#"""
        {
            "venues" : [
                {
                    "id": "\#(id)",
                    "riskyWindow": {
                        "from": "\#(from)",
                        "until": "\#(until)"
                    },
                    "messageType": "M1"
                }
            ]
        }
        """#))
        
        let formatter = ISO8601DateFormatter()
        
        let date = { (string: String) throws -> Date in
            try XCTUnwrap(formatter.date(from: string))
        }
        
        let riskyVenue = try RiskyVenue(
            id: id,
            riskyInterval: DateInterval(start: date(from), end: date(until)),
            messageType: .warnAndInform
        )
        
        let riskyVenues = try endpoint.parse(response)
        
        TS.assert(riskyVenues, equals: [riskyVenue])
    }
    
    func testDecodingListWithVenuesWithMillisecondsInTime() throws {
        // we go from `String` to `Date` even in test to ensure same rounding as app
        let from = "2019-07-04T13:33:03.969Z"
        let until = "2019-07-04T13:33:03.969Z"
        let id = String.random()
        
        let response = HTTPResponse.ok(with: .json(#"""
        {
            "venues" : [
                {
                    "id": "\#(id)",
                    "riskyWindow": {
                        "from": "\#(from)",
                        "until": "\#(until)"
                    },
                    "messageType": "M2"
                }
            ]
        }
        """#))
        
        let formatter = ISO8601DateFormatter()
        formatter.formatOptions.insert(.withFractionalSeconds)
        
        let date = { (string: String) throws -> Date in
            try XCTUnwrap(formatter.date(from: string))
        }
        
        let riskyVenue = try RiskyVenue(
            id: id,
            riskyInterval: DateInterval(start: date(from), end: date(until)),
            messageType: .warnAndBookATest
        )
        
        let riskyVenues = try endpoint.parse(response)
        
        TS.assert(riskyVenues, equals: [riskyVenue])
    }
    
    func testDecodingListWithoutMessageType() throws {
        // we go from `String` to `Date` even in test to ensure same rounding as app
        let from = "2019-07-04T13:33:03Z"
        let until = "2019-07-04T13:33:03Z"
        let id = String.random()
        
        let response = HTTPResponse.ok(with: .json(#"""
        {
            "venues" : [
                {
                    "id": "\#(id)",
                    "riskyWindow": {
                        "from": "\#(from)",
                        "until": "\#(until)"
                    },
                    "messageType": "M1"
                }
            ]
        }
        """#))
        
        let formatter = ISO8601DateFormatter()
        
        let date = { (string: String) throws -> Date in
            try XCTUnwrap(formatter.date(from: string))
        }
        
        let riskyVenue = try RiskyVenue(
            id: id,
            riskyInterval: DateInterval(start: date(from), end: date(until)),
            messageType: .warnAndInform
        )
        
        do {
            let riskyVenues = try endpoint.parse(response)
            TS.assert(riskyVenues, equals: [riskyVenue])
        } catch {
            print(error)
        }
        
    }
    
}
