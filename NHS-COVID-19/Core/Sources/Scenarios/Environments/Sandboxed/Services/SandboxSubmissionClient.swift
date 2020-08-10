//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Common
import Foundation

class SandboxSubmissionClient: HTTPClient {
    private let queue = DispatchQueue(label: "sandbox-submission-client")
    func perform(_ request: HTTPRequest) -> AnyPublisher<HTTPResponse, HTTPRequestError> {
        Result.success(.ok(with: .empty)).publisher
            .receive(on: queue)
            .eraseToAnyPublisher()
    }
}
