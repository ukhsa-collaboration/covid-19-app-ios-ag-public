//
// Copyright © 2020 NHSX. All rights reserved.
//

import Combine
import Foundation

protocol HasWrappedValue {
    associatedtype Value
    var wrappedValue: Value { get }
    var _wrappedValue: Any { get }
}

public class DomainProperty<Value> {
    
    public var publisher: AnyPublisher<Value, Never>
    
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
}

extension Publisher where Failure == Never {
    
    /// Creates an `DomainProperty` from the publisher.
    func domainProperty() -> DomainProperty<Output> {
        DomainProperty(self)
    }
    
}
