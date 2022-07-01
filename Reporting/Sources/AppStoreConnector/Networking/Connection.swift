//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Foundation

public class Connection {

    public enum Errors: Error {
        case httpError(statusCode: Int)
        case urlError(base: URLError)
    }

    private let requestGenerator: RequestGenerator
    private let networkingDelegate: NetworkingDelegate

    init(requestGenerator: RequestGenerator, networkingDelegate: NetworkingDelegate) {
        self.networkingDelegate = networkingDelegate
        self.requestGenerator = requestGenerator
    }

    public func request(_ path: String) -> AnyPublisher<Data, Errors> {
        let request = requestGenerator.request(for: path)
        return networkingDelegate.response(for: request)
            .mapError { Errors.urlError(base: $0) }
            .flatMap { res -> AnyPublisher<Data, Errors> in
                switch res.response.statusCode {
                case 200 ..< 300:
                    return Just(res.data).mapError(absurd).eraseToAnyPublisher()
                default:
                    return Fail(error: .httpError(statusCode: res.response.statusCode)).eraseToAnyPublisher()
                }
            }.eraseToAnyPublisher()
    }

}

private func absurd<Result>(_ never: Never) -> Result {}
