//
// Copyright © 2020 NHSX. All rights reserved.
//

import AppStoreConnector
import XCTest

private struct Environment: Decodable {
    var keyId: String
    var issuerId: String
    var keyFilePath: String
    var logFilePath: String
}

private extension ProcessInfo {

    func decodeEnvironments<T: Decodable>(as type: T.Type) throws -> T {
        let data = try JSONEncoder().encode(environment)

        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase
        return try decoder.decode(type, from: data)
    }

}

private class IntegrationContext {

    let connection: Connection
    let misconfiguredConnection: Connection

    private let _log: (String) -> Void

    init() throws {
        let environment = try ProcessInfo.processInfo.decodeEnvironments(as: Environment.self)

        let keyFile = URL(fileURLWithPath: environment.keyFilePath)
        let key = try EC256PrivateKey(contentsOf: keyFile)

        connection = Client(
            key: key,
            keyID: environment.keyId,
            issuerID: environment.issuerId
        ).connection

        misconfiguredConnection = Client(
            key: key,
            keyID: environment.keyId,
            issuerID: UUID().uuidString
        ).connection

        var logBody = "\(Date())\n"

        _log = { message in
            logBody.append(contentsOf: message)
            logBody.append("\n")
            try! logBody.write(toFile: environment.logFilePath, atomically: true, encoding: .utf8)
        }
    }

    func log(_ message: String) {
        _log(message)
    }

    func log(_ data: Data) {
        log(String(data: data, encoding: .utf8)!)
    }

    func log<T>(_ value: T) {
        log("\(value)")
    }

}

class IntegrationTests: XCTestCase {

    private var c: IntegrationContext!

    override func setUpWithError() throws {
        do {
            try super.setUpWithError()
            c = try IntegrationContext()
        } catch {
            throw XCTSkip("Integration context not available")
        }
    }

    func testUsingMisconfiguredClientReturnsError() {
        let response = c.misconfiguredConnection.request("/apps")

        let expectation = self.expectation(description: "Request finishes")
        let cancellation = response.sink(
            receiveCompletion: { completion in
                switch completion {
                case .failure(.httpError(statusCode: 401)):
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

    func testHittingBasicAPI() throws {
        let response = c.connection.request("/apps")

        let expectation = self.expectation(description: "Request finishes")
        let cancellation = response.sink(
            receiveCompletion: { completion in
                switch completion {
                case .failure(let error):
                    XCTFail("Unexpected error: \(error)")
                case .finished:
                    expectation.fulfill()
                }
            },
            receiveValue: { response in
                self.c.log(response)
            }
        )
        defer {
            cancellation.cancel()
        }
        waitForExpectations(timeout: 30, handler: nil)

    }

}
