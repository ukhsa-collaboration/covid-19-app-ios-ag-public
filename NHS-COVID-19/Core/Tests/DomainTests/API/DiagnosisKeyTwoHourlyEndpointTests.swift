//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import XCTest
@testable import Domain

class DiagnosisKeyTwoHourlyEndpointTests: XCTestCase {
    
    func testHTTPRequest() throws {
        
        do {
            let increment = Increment.twoHourly(
                Increment.Day(year: 2020, month: 6, day: 26),
                Increment.TwoHour(value: 1)
            )
            let endpoint = DiagnosisKeyTwoHourlyEndpoint()
            let httpRequest = try endpoint.request(for: increment)
            XCTAssertEqual("/distribution/two-hourly/2020062601.zip", httpRequest.path)
        }
        
        do {
            let increment = Increment.twoHourly(
                Increment.Day(year: 2020, month: 6, day: 6),
                Increment.TwoHour(value: 12)
            )
            let endpoint = DiagnosisKeyTwoHourlyEndpoint()
            let httpRequest = try endpoint.request(for: increment)
            XCTAssertEqual("/distribution/two-hourly/2020060612.zip", httpRequest.path)
        }
        
        do {
            let increment = Increment.twoHourly(
                Increment.Day(year: 2020, month: 11, day: 13),
                Increment.TwoHour(value: 0)
            )
            let endpoint = DiagnosisKeyTwoHourlyEndpoint()
            let httpRequest = try endpoint.request(for: increment)
            XCTAssertEqual("/distribution/two-hourly/2020111300.zip", httpRequest.path)
        }
        
    }
    
    func testHTTPResponse() throws {
        let endpoint = DiagnosisKeyTwoHourlyEndpoint()
        let httpResponse = HTTPResponse(httpUrlResponse: HTTPURLResponse(), bodyContent: Data())
        _ = try endpoint.parse(httpResponse)
    }
}
