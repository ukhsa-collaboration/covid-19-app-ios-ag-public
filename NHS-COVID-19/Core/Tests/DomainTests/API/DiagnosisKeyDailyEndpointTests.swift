//
// Copyright © 2020 NHSX. All rights reserved.
//

import Common
import XCTest
@testable import Domain

class DiagnosisKeyDailyEndpointTests: XCTestCase {

    func testHTTPRequest() throws {
        let endpoint = DiagnosisKeyDailyEndpoint()

        do {
            let increment = Increment.daily(Increment.Day(year: 2020, month: 6, day: 26))
            let httpRequest = try endpoint.request(for: increment)
            XCTAssertEqual("/distribution/daily/2020062600.zip", httpRequest.path)
        }

        do {
            let increment = Increment.daily(Increment.Day(year: 2020, month: 6, day: 6))
            let httpRequest = try endpoint.request(for: increment)
            XCTAssertEqual("/distribution/daily/2020060600.zip", httpRequest.path)
        }

        do {
            let increment = Increment.daily(Increment.Day(year: 2020, month: 11, day: 13))
            let httpRequest = try endpoint.request(for: increment)
            XCTAssertEqual("/distribution/daily/2020111300.zip", httpRequest.path)
        }

    }

    func testHTTPResponse() throws {
        let endpoint = DiagnosisKeyDailyEndpoint()
        let httpResponse = HTTPResponse(httpUrlResponse: HTTPURLResponse(), bodyContent: Data())
        _ = try endpoint.parse(httpResponse)
    }
}
