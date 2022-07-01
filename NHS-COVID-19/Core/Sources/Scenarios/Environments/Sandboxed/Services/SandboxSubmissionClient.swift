//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Common
import Foundation

class SandboxSubmissionClient: HTTPClient {

    private let initialState: Sandbox.InitialState
    private let queue = DispatchQueue(label: "sandbox-submission-client")

    init(initialState: Sandbox.InitialState) {
        self.initialState = initialState
    }

    func perform(_ request: HTTPRequest) -> AnyPublisher<HTTPResponse, HTTPRequestError> {
        _perform(request).publisher
            .receive(on: queue)
            .eraseToAnyPublisher()
    }

    private func _perform(_ request: HTTPRequest) -> Result<HTTPResponse, HTTPRequestError> {
        if request.path == "/virology-test/v2/order" {
            let websiteURL = URL(string: "https://example.com")!

            let response = HTTPResponse.ok(with: .json(#"""
            {
                "websiteUrlWithQuery": "\#(websiteURL)",
                "tokenParameterValue": "\#(UUID().uuidString)",
                "testResultPollingToken" : "\#(UUID().uuidString)",
                "diagnosisKeySubmissionToken": "\#(UUID().uuidString)"
            }
            """#))

            return Result.success(response)
        }

        if request.path == "/virology-test/v2/cta-exchange" {
            let date = GregorianDay.today.startDate(in: .utc)
            let dateString = ISO8601DateFormatter().string(from: date)

            let testResult = initialState.testResult?.uppercased() ?? "POSITIVE"
            let keySubmissionSupported = initialState.supportsKeySubmission
            let requiresConfirmatoryTest = initialState.requiresConfirmatoryTest
            let testKitType = initialState.testKitType

            let response = HTTPResponse.ok(with: .json(#"""
            {
            "testEndDate": "\#(dateString)",
            "testResult": "\#(testResult)",
            "testKit":"\#(testKitType)",
            "diagnosisKeySubmissionToken": "\#(UUID().uuidString)",
            "diagnosisKeySubmissionSupported": \#(keySubmissionSupported),
            "requiresConfirmatoryTest": \#(requiresConfirmatoryTest),
            "shouldOfferFollowUpTest": \#(requiresConfirmatoryTest)
            }
            """#))
            return Result.success(response)
        }

        if request.path == "/activation/request" {
            return Result.success(.ok(with: .empty))
        }

        if request.path == "/submission/diagnosis-keys" {
            return Result.success(.ok(with: .empty))
        }

        if request.path == "/isolation-payment/ipc-token/update" {
            let websiteURL = URL(string: "https://example.com")!
            let response = HTTPResponse.ok(with: .json(#"""
            {
                "websiteUrlWithQuery": "\#(websiteURL)",
            }
            """#))

            return Result.success(response)
        }

        if request.path == "/submission/risky-venue-history" {
            return Result.success(.ok(with: .empty))
        }

        return Result.failure(.rejectedRequest(underlyingError: SimpleError("")))
    }
}
