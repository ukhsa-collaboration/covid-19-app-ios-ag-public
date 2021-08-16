//
// Copyright © 2021 DHSC. All rights reserved.
//

import Combine
import Foundation

/// An observable object that guarantees to publish its changes on the main thread.
///
/// This type is suitable for containing published values that are used to drive UI.
@propertyWrapper
public class InterfaceProperty<Value>: ObservableObject {
    private let publisher: AnyPublisher<Value, Never>
    
    @Published
    public private(set) var wrappedValue: Value
    
    public var projectedValue: InterfaceProperty<Value> {
        self
    }
    
    private var cancellables = [AnyCancellable]()
    
    fileprivate init<P: Publisher>(_ upstream: P, initialValue: Value) where P.Output == Value, P.Failure == Never {
        publisher = upstream.eraseToAnyPublisher()
        wrappedValue = initialValue
        
        upstream.sink { [weak self] value in
            self?.wrappedValue = value
        }.store(in: &cancellables)
    }
    
    public func sink(_ receiveValue: @escaping (Value) -> Void) {
        $wrappedValue.sink(receiveValue: receiveValue).store(in: &cancellables)
    }
}

extension Publisher where Failure == Never {
    
    /// Creates an `InterfaceProperty` from the publisher.
    /// - Parameter initialValue: The value to use before the receiver emits any values.
    public func property(initialValue: Output) -> InterfaceProperty<Output> {
        InterfaceProperty(regulate(as: .modelChange), initialValue: initialValue)
    }
    
}

extension InterfaceProperty {
    
    public static func constant(_ value: Value) -> InterfaceProperty<Value> {
        InterfaceProperty(Empty(), initialValue: value)
    }
    
}

extension InterfaceProperty {
    public func map<T>(_ transform: @escaping (Value) -> T) -> InterfaceProperty<T> {
        return publisher.map(transform).property(initialValue: transform(wrappedValue))
    }
}
