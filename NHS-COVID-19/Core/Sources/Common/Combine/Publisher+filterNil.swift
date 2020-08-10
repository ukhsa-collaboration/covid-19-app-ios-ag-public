//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Foundation

public extension Publisher {
    func filterNil<Output, Failure>() -> AnyPublisher<Output, Failure> where Self.Output == Output?, Self.Failure == Failure {
        flatMap { Optional.Publisher($0).setFailureType(to: Failure.self) }.eraseToAnyPublisher()
    }
}
