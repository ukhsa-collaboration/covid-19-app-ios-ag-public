//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation

class SandboxSubmissionClient: HTTPClient {
    private let queue = DispatchQueue(label: "sandbox-submission-client")
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
        
        return Result.failure(.rejectedRequest(underlyingError: SimpleError("")))
    }
}
