//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import XCTest
@testable import AppStoreConnector

private struct MockRequestGenerator: RequestGenerator {
    var request: URLRequest
    func request(for path: String) -> URLRequest {
        request
    }
}

private extension MockRequestGenerator {
    
    init() {
        let request = URLRequest(url: URL(string: "https://somewhere")!)
        self.init(request: request)
    }
    
}

private struct MockNetworkingDelegate: NetworkingDelegate {
    var response: HTTPURLResponse
    var data: Data
    
    func response(for request: URLRequest) -> AnyPublisher<(response: HTTPURLResponse, data: Data), URLError> {
        Just((response, data)).mapError(absurd).eraseToAnyPublisher()
    }
}

class ConnectionTests: XCTestCase {
    
    func testHTTPErrorsAreCaptured() throws {
        let generator = MockRequestGenerator()
        let networkingDelegate = MockNetworkingDelegate(
            response: HTTPURLResponse(
                url: generator.request.url!,
                statusCode: 403,
                httpVersion: nil,
                headerFields: nil
            )!,
            data: Data()
        )
        
        let connection = Connection(requestGenerator: generator, networkingDelegate: networkingDelegate)
        
        let expectation = self.expectation(description: "Request finishes")
        let cancellation = connection.request("").sink(
            receiveCompletion: { completion in
                switch completion {
                case .failure(.httpError(statusCode: 403)):
                    expectation.fulfill()
                case .failure(let error):
                    XCTFail("Unexpected error: \(error)")
                case .finished:
                    XCTFail("Expected failure")
                }
            },
            receiveValue: { _ in
                XCTFail("Expected call to fail")
            }
        )
        defer {
            cancellation.cancel()
        }
        waitForExpectations(timeout: 1, handler: nil)
    }
    
}

private func absurd<Result>(_ never: Never) -> Result {}
