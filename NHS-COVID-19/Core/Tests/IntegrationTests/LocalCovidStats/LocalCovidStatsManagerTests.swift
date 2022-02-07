//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import XCTest
@testable import Domain

class LocalCovidStatsManagerTests: XCTestCase {
    private var manager: LocalCovidStatsManager!
    private var httpClient: MockLocalStatsHttpClient!
    
    override func setUp() {
        httpClient = MockLocalStatsHttpClient()
        manager = LocalCovidStatsManager(
            httpClient: httpClient
        )
    }
    
    func testFetchLocalStats() {
        _ = manager.fetchLocalCovidStats()
        XCTAssertEqual(httpClient.amountOfCalls, 1)
    }
}

private class MockLocalStatsHttpClient: HTTPClient {
    var amountOfCalls = 0
    var response: HTTPResponse?
    
    func perform(_ request: HTTPRequest) -> AnyPublisher<HTTPResponse, HTTPRequestError> {
        amountOfCalls += 1
        if let response = response {
            return Result.success(response).publisher.eraseToAnyPublisher()
        } else {
            return Empty().eraseToAnyPublisher()
        }
    }
}
