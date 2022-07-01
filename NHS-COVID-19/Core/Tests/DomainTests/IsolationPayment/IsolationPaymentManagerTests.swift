//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import TestSupport
import XCTest
@testable import Domain
@testable import Scenarios

class IsolationPaymentManagerTests: XCTestCase {
    var httpClient: MockHTTPClient!
    var infoProvider: IsolationPaymentInfoProvider!

    override func setUp() {
        httpClient = MockHTTPClient()
        httpClient.response = .success(HTTPResponse.ok(with: .json("""
        {
            "ipcToken": "\(UUID().uuidString)",
            "isEnabled": true
        }
        """)))
        infoProvider = MockIsolationPaymentInfoProvider()
    }

    func testBasic() throws {
        var toggle: Bool = true
        let manager = IsolationPaymentManager(
            httpClient: httpClient,
            isolationPaymentInfoProvider: infoProvider,
            country: { .england },
            isInCorrectIsolationStateToApplyForFinancialSupport: { toggle }
        )

        XCTAssertNil(infoProvider.load())
        _ = try manager.processCanApplyForFinancialSupport().await()
        XCTAssertNotNil(infoProvider.load())

        toggle = false
        _ = try manager.processCanApplyForFinancialSupport().await()
        XCTAssertNil(infoProvider.load())
    }
}

private class MockIsolationPaymentInfoProvider: IsolationPaymentInfoProvider {
    private var savedState: IsolationPaymentRawState?

    func load() -> IsolationPaymentRawState? {
        return savedState
    }

    func save(_ state: IsolationPaymentRawState) {
        savedState = state
    }

    func delete() {
        savedState = nil
    }
}
