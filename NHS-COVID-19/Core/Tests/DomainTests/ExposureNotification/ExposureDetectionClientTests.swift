//
// Copyright © 2020 NHSX. All rights reserved.
//

import Scenarios
import XCTest
@testable import Domain

class ExposureDetectionClientTests: XCTestCase {
    
    func testGetDailyKeysFetchesFromCorrectEndpoint() throws {
        let httpClient = MockHTTPClient()
        let client = ExposureDetectionClient(distributionClient: httpClient, submissionClient: MockHTTPClient())
        
        let increment = Increment.daily(.init(year: 2020, month: 6, day: 26))
        
        _ = client.getExposureKeys(for: increment)
        let request = try XCTUnwrap(httpClient.lastRequest)
        XCTAssertEqual("/distribution/daily/2020062600.zip", request.path)
    }
    
    func testGetTwoHourlyKeysFetchesFromCorrectEndpoint() throws {
        let httpClient = MockHTTPClient()
        let client = ExposureDetectionClient(distributionClient: httpClient, submissionClient: MockHTTPClient())
        
        let increment = Increment.twoHourly(.init(year: 2020, month: 6, day: 26), .init(value: 1))
        
        _ = client.getExposureKeys(for: increment)
        let request = try XCTUnwrap(httpClient.lastRequest)
        XCTAssertEqual("/distribution/two-hourly/2020062601.zip", request.path)
    }
}
