//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Foundation

public class DomainProperty<Value>: Publisher {
    public typealias Output = Value
    public typealias Failure = Never

    private let publisher: AnyPublisher<Value, Never>
    private var lastReceivedValue: Value!

    public var currentValue: Value {
        publisher.sink { [weak self] value in
            self?.lastReceivedValue = value
        }.cancel()

        return lastReceivedValue
    }

    fileprivate init<P: Publisher>(_ publisher: P) where P.Output == Value, P.Failure == Never {
        self.publisher = publisher.eraseToAnyPublisher()

        publisher.sink { [weak self] value in
            self?.lastReceivedValue = value
        }.cancel()

        assert(lastReceivedValue != nil)
    }

    public func receive<S>(subscriber: S) where S: Subscriber, S.Failure == Never, S.Input == Value {
        publisher.receive(subscriber: subscriber)
    }
}

extension Publisher where Failure == Never {

    /// Creates an `DomainProperty` from the publisher.
    func domainProperty() -> DomainProperty<Output> {
        DomainProperty(self)
    }

}

extension DomainProperty {
    public static func constant(_ value: Value) -> DomainProperty<Value> {
        DomainProperty(Just(value))
    }
}

extension DomainProperty {
    public func map<T>(_ transform: @escaping (Value) -> T) -> DomainProperty<T> {
        publisher.map(transform).domainProperty()
    }
}
