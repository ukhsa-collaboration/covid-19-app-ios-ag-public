//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Foundation

public final class HTTPObfuscationClient: HTTPClient {
    private let client: HTTPClient
    private let obfuscator = HTTPHeadersObfuscator()
    
    public init(
        remote: URLRequestProviding,
        session: URLSessionProtocol = URLSession.shared
    ) {
        client = URLSessionHTTPClient(
            remote: remote,
            session: session
        )
    }
    
    public func perform(_ request: HTTPRequest) -> AnyPublisher<HTTPResponse, HTTPRequestError> {
        let preparedRequest = obfuscator.prepare(request)
        return client.perform(preparedRequest).eraseToAnyPublisher()
    }
}
