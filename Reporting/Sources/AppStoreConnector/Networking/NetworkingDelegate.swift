//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Foundation

public protocol NetworkingDelegate {

    func response(for request: URLRequest) -> AnyPublisher<(response: HTTPURLResponse, data: Data), URLError>

}

extension URLSession: NetworkingDelegate {

    public func response(for request: URLRequest) -> AnyPublisher<(response: HTTPURLResponse, data: Data), URLError> {
        dataTaskPublisher(for: request)
            .map { data, response in
                (response as! HTTPURLResponse, data)
            }.eraseToAnyPublisher()
    }

}
