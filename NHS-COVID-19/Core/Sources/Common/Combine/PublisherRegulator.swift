//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine

/// A protocol for regulating publishers
public protocol PublisherRegulator {
    func regulate<T: Publisher>(_ publisher: T) -> AnyPublisher<T.Output, T.Failure>
}
